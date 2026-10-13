use anyhow::Result;
use rangers_tools::{
    compiler::emit::Emitter,
    inspect::{signatures, sizes},
    matching::session,
    project::Project,
    util,
};
use serde_json::json;
use std::{fs, path::PathBuf};

struct Fixture(PathBuf);
impl Fixture {
    fn new(name: &str) -> Result<Self> {
        let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join(".local/tests")
            .join(format!("{name}-{}", std::process::id()));
        util::remove_generated([root.clone()])?;
        fs::create_dir_all(root.join("source"))?;
        fs::write(
            root.join("project.toml"),
            "[project]\nsource='source'\ncache='.local'\nbinary='native.exe'\ndatabase='native.i64'\n",
        )?;
        Ok(Self(root))
    }
}
impl Drop for Fixture {
    fn drop(&mut self) {
        let _ = util::remove_generated([self.0.clone()]);
    }
}

#[test]
fn nested_native_declarations_stay_in_their_lexical_scope() -> Result<()> {
    let fixture = Fixture::new("nested-declarations")?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        include_str!("delphi/initialized_globals/Rangers.dpr"),
    )?;
    fs::write(
        fixture.0.join("source/Helpers.pas"),
        r#"unit Helpers;
interface
function Compute(Value: Integer): Integer; // @addr $1000
implementation
{ @routine $1000 Compute }
function Compute(Value: Integer): Integer;
  // @nested $1010 AddOffset
  function AddOffset(Number: Integer): Integer; // @addr $1010
    // @nested $1020 DoubleNumber
    function DoubleNumber: Integer; // @addr $1020 @ida "int __cdecl $name(void *ParentFrame);"
    begin Result := Number * 2; end;
  begin Result := DoubleNumber + Value; end;
begin Result := AddOffset(3); end;
{ @end $1000 }
end.
"#,
    )?;
    fs::write(
        fixture.0.join("source/OtherHelpers.pas"),
        r#"unit OtherHelpers;
interface
function OtherCompute(Value: Integer): Integer; // @addr $1030
implementation
{ @routine $1030 OtherCompute }
function OtherCompute(Value: Integer): Integer;
  // @nested $1040 AddOffset
  function AddOffset(Number: Integer): Integer; // @addr $1040 @ida "int __usercall $name@<eax>(int Number@<eax>, void *ParentFrame@<^0>);"
  begin Result := Number + Value; end;
begin Result := AddOffset(5); end;
{ @end $1030 }
end.
"#,
    )?;
    let mut project = Project::open(&fixture.0)?;
    let nested = project.routine("$1010")?;
    assert_eq!(nested.name, "Compute_AddOffset");
    assert_eq!(nested.data["local_name"], "AddOffset");
    assert!(!nested.meta.contains_key("ida"));
    let nested = nested.clone();
    assert!(
        project
            .compiler
            .prototype(&nested)?
            .unwrap()
            .contains("ParentFrame@<^0>")
    );
    let manifest = project.compiler.build()?;
    let function = manifest["functions"]
        .as_array()
        .unwrap()
        .iter()
        .find(|f| f["addr"] == 0x1010)
        .unwrap();
    assert_eq!(function["stackpop"], 0);
    assert_eq!(
        project.routine("$1020")?.name,
        "Compute_AddOffset_DoubleNumber"
    );
    assert_eq!(project.routine("$1040")?.name, "OtherCompute_AddOffset");
    assert_eq!(session::select(&project, &[])?.len(), 5);
    let output = fixture.0.join("generated");
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let generated = fs::read_to_string(output.join("Helpers.pas"))?;
    let (interface, implementation) = generated.split_once("implementation").unwrap();
    assert!(!interface.contains("AddOffset") && !interface.contains("DoubleNumber"));
    assert_eq!(implementation.matches("function AddOffset(").count(), 1);
    assert_eq!(implementation.matches("function DoubleNumber:").count(), 1);
    assert!(implementation.contains("begin Result := Number * 2; end;"));
    Ok(())
}

#[test]
fn generated_units_preserve_initializers_and_source_ownership() -> Result<()> {
    let fixture = Fixture::new("source-generation")?;
    fs::write(
        fixture.0.join("source/State.pas"),
        include_str!("delphi/initialized_globals/State.pas")
            .replace(
                "function ReadState: Cardinal;\nbegin",
                "function ReadState: Cardinal;\nvar Rangers: record Value: Cardinal; end;\nbegin",
            )
            .replace(
                "Result := Encoded;",
                "Rangers.Value := Encoded;\n  Result := Rangers.Value;",
            )
            .replace(
                "implementation",
                "implementation\n\
                 function Matches(Value: TObject; const Expected: TClass): Boolean; inline;\n\
                 var LocalClass: TClass;\n\
                 begin\n\
                   LocalClass := Expected;\n\
                   Result := (Value is Expected) and (Value is LocalClass) and (Value is TObject);\n\
                 end;\n",
            ),
    )?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        r#"program Rangers; uses State;
type TProgramMarker = class(TObject) // @size $04
public
  procedure Ping; // @addr $1404
end;
{ @routine $1404 TProgramMarker_Ping }
procedure TProgramMarker.Ping; begin end;
{ @end $1404 }
{ @routine $1400 ProgramHelper }
procedure ProgramHelper; // @addr $1400
var LocalCount: Integer;
begin LocalCount := 1; end;
{ @end $1400 }
{$I RecoveredExports.inc}
{ @routine $1300 MainEntry }
begin ProgramHelper; end.
{ @end $1300 }
"#,
    )?;
    fs::write(
        fixture.0.join("source/Rangers.pas"),
        "unit Rangers; interface\nprocedure MainEntry; // @addr $1300\nimplementation end.\n",
    )?;
    fs::write(
        fixture.0.join("source/System.pas"),
        "unit System; interface\ntype TObject = class // @size $04\nend;\nTClass = class of TObject;\nimplementation end.\n",
    )?;
    fs::write(
        fixture.0.join("source/Dormant.pas"),
        "unit Dormant; interface\nprocedure Unused; // @addr $1200\nimplementation\n{ @routine $1200 Unused }\nprocedure Unused; begin end;\n{ @end $1200 }\nend.\n",
    )?;
    let mut project = Project::open(&fixture.0)?;
    assert_eq!(project.bodies()?.len(), 6);
    assert_eq!(project.routine("$1000")?.name, "ReadState");
    assert!(project.routine("Absent").is_err());
    assert_eq!(session::select(&project, &["ReadState".into()])?.len(), 1);
    let declaration = project.routine("ReadState")?;
    assert!(
        project
            .store_body(
                &declaration,
                "function ReadState: Cardinal; begin Result := 1; end;",
                false
            )
            .is_err()
    );
    let output = fixture.0.join("generated");
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let generated = fs::read_to_string(output.join("State.pas"))?;
    assert!(generated.contains("$B1CD15D3"));
    assert!(generated.contains("AutoSave.sav") && generated.contains("QuickSave.sav"));
    assert!(!generated.contains("RangersSupport"));
    assert!(!generated.contains("SysUtils"));
    assert!(!generated.contains("Math"));
    assert!(!generated.contains("uses Rangers;"));
    assert!(generated.contains("Value is Expected") && generated.contains("Value is LocalClass"));
    assert!(generated.contains("TObject.ClassName;"));
    assert!(
        !generated.contains("Expected.ClassName;") && !generated.contains("LocalClass.ClassName;")
    );
    assert!(fs::read_to_string(output.join("Rangers.dpr"))?.contains("Dormant"));
    assert!(!output.join("Rangers.pas").exists());
    assert_eq!(project.bodies()?.iter().filter(|b| b.program).count(), 1);
    assert!(fs::read_to_string(output.join("RecoveredExports.inc"))?.contains("Dormant.Unused"));
    let layout = fixture.0.join("layout");
    Emitter::new(&mut project)?.write_units(&layout, false)?;
    assert!(!fs::read_to_string(layout.join("Rangers.dpr"))?.contains("Dormant"));
    assert!(fs::read_to_string(layout.join("RecoveredExports.inc"))?.is_empty());
    project.store_body(
        &declaration,
        "function ReadState: Cardinal; begin Result := 1; end;",
        true,
    )?;
    let updated = Project::open(&fixture.0)?;
    assert_eq!(updated.bodies()?.len(), 6);
    assert!(
        updated
            .bodies()?
            .iter()
            .any(|b| b.text.contains("Result := 1"))
    );
    Ok(())
}

#[test]
fn public_inline_helpers_preserve_source_without_native_addresses() -> Result<()> {
    let fixture = Fixture::new("public-inline-helpers")?;
    fs::write(
        fixture.0.join("source/Geometry.pas"),
        r#"unit Geometry;
interface
type TCoordinate = record // @size 8
  X: Integer; // @offset 0
  Y: Integer; // @offset 4
end;
function SquaredDistance(const Point: TCoordinate; X, Y: Integer): Integer; inline;
function NativeInline(Value: Integer): Integer; inline; // @addr $1100
implementation
function SquaredDistance(const Point: TCoordinate; X, Y: Integer): Integer; inline;
begin Result := Sqr(Point.X - X) + Sqr(Point.Y - Y); end;
{ @routine $1100 NativeInline }
function NativeInline(Value: Integer): Integer;
begin Result := Value * 2; end;
{ @end $1100 }
end.
"#,
    )?;
    fs::write(
        fixture.0.join("source/Consumer.pas"),
        r#"unit Consumer;
interface
function Distance: Integer; // @addr $1200
implementation
uses Geometry;
{ @routine $1200 Distance }
function Distance: Integer;
var Point: TCoordinate;
begin Point.X := 3; Point.Y := 4; Result := SquaredDistance(Point, 0, 0); end;
{ @end $1200 }
end.
"#,
    )?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        "program Rangers; uses Consumer;\n{ @routine $1300 MainEntry }\nbegin Distance; end.\n{ @end $1300 }\n",
    )?;
    fs::write(
        fixture.0.join("source/Rangers.pas"),
        "unit Rangers; interface\nprocedure MainEntry; // @addr $1300\nimplementation end.\n",
    )?;
    let mut project = Project::open(&fixture.0)?;
    assert!(project.routine("SquaredDistance").is_err());
    assert_eq!(project.routine("NativeInline")?.meta["addr"], 0x1100);
    let manifest = project.compiler.build()?;
    let functions = manifest["functions"].as_array().unwrap();
    assert_eq!(functions.len(), 3);
    assert!(functions.iter().all(|f| f["name"] != "SquaredDistance"));
    assert_eq!(project.bodies()?.len(), 3);
    for retain_all in [false, true] {
        let output = fixture.0.join(format!("generated-{retain_all}"));
        Emitter::new(&mut project)?.write_units(&output, retain_all)?;
        let generated = fs::read_to_string(output.join("Geometry.pas"))?;
        let interface = generated.split("implementation").next().unwrap();
        assert!(interface.contains("function SquaredDistance"));
        assert!(interface.contains("Integer; inline;"));
        assert!(interface.contains("TCoordinate = record"));
        assert!(generated.contains("Result := Sqr(Point.X - X) + Sqr(Point.Y - Y)"));
        assert!(!generated.contains("MissingImplementation"));
        assert!(fs::read_to_string(output.join("Consumer.pas"))?.contains("Geometry"));
        assert!(
            !fs::read_to_string(output.join("RecoveredExports.inc"))?.contains("SquaredDistance")
        );
    }
    Ok(())
}

#[test]
fn public_array_metadata_preserves_source_order_across_type_sections() -> Result<()> {
    let fixture = Fixture::new("public-array-order")?;
    fs::create_dir_all(fixture.0.join("source/runtime"))?;
    fs::create_dir(fixture.0.join("lib"))?;
    fs::write(fixture.0.join("lib/ActiveX.dcu"), [])?;
    fs::write(
        fixture.0.join("source/runtime/ActiveX.pas"),
        "unit ActiveX; interface\nconst ExternalCount = 2;\nprocedure ExternalEntry; stdcall; external 'fixture.dll'; // @addr $1200\nimplementation end.\n",
    )?;
    let settings = fixture.0.join("project.toml");
    fs::write(
        &settings,
        format!(
            "{}\n[compiler]\nlibrary='lib'\n",
            fs::read_to_string(&settings)?
        ),
    )?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        "program Rangers; uses Palettes, SecondPalette, Empty, ActiveX;\n{ @routine $1100 MainEntry }\nbegin end.\n{ @end $1100 }\n",
    )?;
    fs::write(
        fixture.0.join("source/Rangers.pas"),
        "unit Rangers; interface\nprocedure MainEntry; // @addr $1100\nimplementation end.\n",
    )?;
    fs::write(
        fixture.0.join("source/Empty.pas"),
        "unit Empty; interface implementation end.\n",
    )?;
    let second_palette = fixture.0.join("source/SecondPalette.pas");
    fs::write(
        &second_palette,
        "unit SecondPalette; interface\ntype TPalette = array[0..8] of Single;\nimplementation end.\n",
    )?;
    fs::write(
        fixture.0.join("source/Palettes.pas"),
        r#"unit Palettes; interface
type TPalette = array[0..8] of Single;
var First: array of TPalette; // @addr $2000
procedure OrderedExternal; stdcall; external 'fixture.dll'; // @addr $1204
var Second: array of TPalette; // @addr $2004
type TEffect = class // @size $14
  Flag: Byte; // @offset $04
  Scale: Double; // @offset $08
  Active: Byte; // @offset $10
  procedure Update; // @addr $1000
end;
implementation
{ @routine $1000 TEffect_Update }
procedure TEffect.Update;
begin ExternalEntry; OrderedExternal; SetLength(First, ExternalCount); SetLength(Second, 3); Scale := Flag; end;
{ @end $1000 }
end.
"#,
    )?;
    let mut project = Project::open(&fixture.0)?;
    let output = fixture.0.join("generated");
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let generated = fs::read_to_string(output.join("Palettes.pas"))?;
    assert!(output.join("Empty.pas").exists());
    assert!(!output.join("ActiveX.pas").exists());
    assert!(
        fs::read_to_string(output.join("SecondPalette.pas"))?
            .contains("TPalette = array[0..8] of Single;")
    );
    assert!(!generated.contains("uses SecondPalette"));
    assert!(generated.find("TPalette =").unwrap() < generated.find("First:").unwrap());
    assert!(
        generated.find("First:").unwrap() < generated.find("procedure OrderedExternal;").unwrap()
    );
    assert!(
        generated.find("procedure OrderedExternal;").unwrap() < generated.find("Second:").unwrap()
    );
    assert!(generated.find("Second:").unwrap() < generated.find("TEffect = class(").unwrap());
    assert!(!generated.contains("Gap4:")); // Double field alignment.
    assert!(!generated.contains("Gap11:")); // Class instance size rounds to four bytes.
    fs::write(
        &second_palette,
        "unit SecondPalette; interface\ntype TPalette = array[0..9] of Single;\nimplementation end.\n",
    )?;
    assert!(
        Project::open(&fixture.0)
            .err()
            .unwrap()
            .to_string()
            .contains("duplicate/reserved name TPalette")
    );
    Ok(())
}

#[test]
fn signatures_distinguish_incoming_registers_from_clobbered_locals() -> Result<()> {
    let make = |prefix: &str| json!({"ea":4096,"name":"Test","source":"Test.pas","prefix":prefix,"returns":[[4112,4]],"type":{"callee_cleans":true,"args":[{"name":"A","loc":"al","size":1,"stack":null}]}});
    // mov [ebp-4],eax transports four bytes despite the declared byte; RET 4 also disagrees.
    let report = signatures::audit(&[make("558bec8945fcc20400")])?;
    assert_eq!(
        report["findings"][0]["problems"].as_array().unwrap().len(),
        2
    );
    // A zeroed EAX stored to a local is not an incoming argument home.
    let mut row = make("558bec31c08945fcc3");
    row["returns"] = json!([[4104, 0]]);
    assert!(
        signatures::audit(&[row])?["findings"]
            .as_array()
            .unwrap()
            .is_empty()
    );
    Ok(())
}

#[test]
fn sizes_subtract_metadata_and_split_ownership() -> Result<()> {
    let snapshot = json!({"functions":[{"ea":100,"end":110,"size":10,"chunks":[[100,110]],"import_thunk":false}],"sections":[{"name":"code","low":100,"high":112,"instructions":[[100,4],[104,4],[108,2],[110,2]]}],"metadata":[[104,106,"table"]]});
    let report = json!({"conflicts":[],"issues":[],"units":[{"section":"code","low":100,"high":107,"unit":"aShip"}]});
    let evidence = json!({"ranges":[]});
    let measured = sizes::measure(&snapshot, &report, &evidence)?;
    assert_eq!(measured["total_bytes"], 10);
    assert_eq!(measured["counts"]["campaign"]["bytes"], 6);
    assert_eq!(measured["counts"]["unresolved"]["bytes"], 4);
    assert_eq!(measured["outside_function_code_bytes"], 2);
    assert_eq!(measured["metadata_corrections"][0]["removed_bytes"], 2);
    Ok(())
}

#[test]
#[ignore = "requires ./decomp worker start; compiles only, never executes the fixture"]
fn incremental_dcc_retries_preserve_valid_units_and_handle_reverts() -> Result<()> {
    use rangers_tools::compiler::{build, worker::Toolchain};
    use rangers_tools::native::image::Image;
    let fixture = Fixture::new("dcc-incremental")?;
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let tc = Toolchain::load(&root, None)?;
    let source = fixture.0.join("source/Retry.dpr");
    let directory = fixture.0.join("build");
    let provider = fixture.0.join("source/Provider.pas");
    let consumer = fixture.0.join("source/Consumer.pas");
    let provider_text = "unit Provider; interface function ReadValue: Integer; implementation function ReadValue: Integer; begin Result := 1; end; end.\n";
    let consumer_text = "unit Consumer; interface function ReadConsumer: Integer; implementation uses Provider; function ReadConsumer: Integer; begin Result := ReadValue; end; end.\n";
    fs::write(
        &source,
        "program Retry; uses Provider, Consumer; begin Writeln(ReadConsumer); end.\n",
    )?;
    fs::write(&provider, provider_text)?;
    fs::write(&consumer, consumer_text)?;
    let compile = || build::source(&tc, &source, &[], Some(&directory));
    let original = compile()?;
    assert_eq!(original.status, 0, "{}", original.output);
    let provider_dcu = fs::read(directory.join("Provider.dcu"))?;
    fs::write(
        &provider,
        provider_text.replace("Result := 1", "Result := 2"),
    )?;
    fs::write(
        &consumer,
        consumer_text.replace("Result := ReadValue", "Result := MissingIdentifier"),
    )?;
    let failed = compile()?;
    assert_eq!(failed.status, 1, "{}", failed.output);
    assert_ne!(fs::read(directory.join("Provider.dcu"))?, provider_dcu);
    let state: serde_json::Value =
        serde_json::from_slice(&fs::read(directory.join("Retry.compiler-state.json"))?)?;
    assert_eq!(state["result"]["rebuild"], false);
    // Revert immediately, including within Delphi's two-second timestamp window.
    fs::write(&provider, provider_text)?;
    fs::write(&consumer, consumer_text)?;
    let restored = compile()?;
    assert_eq!(restored.status, 0, "{}", restored.output);
    let state: serde_json::Value =
        serde_json::from_slice(&fs::read(directory.join("Retry.compiler-state.json"))?)?;
    assert_eq!(state["result"]["rebuild"], false);
    let code = |bytes| -> Result<Vec<u8>> {
        let image = Image::parse(bytes)?;
        let section = image.sections.iter().find(|s| s.flags & 0x20 != 0).unwrap();
        Ok(image
            .read_exact(section.address, section.virtual_size as usize)?
            .to_vec())
    };
    assert_eq!(code(original.image_data)?, code(restored.image_data)?);
    assert!(compile()?.reused);
    println!(
        "DCC32: initial {:.3}s; diagnostic {:.3}s; repaired {:.3}s",
        original.seconds, failed.seconds, restored.seconds
    );
    Ok(())
}

#[test]
fn generated_cleanup_does_not_follow_symlinks() -> Result<()> {
    let fixture = Fixture::new("generated-cleanup")?;
    let kept = fixture.0.join("source/kept.pas");
    fs::write(&kept, "unit Kept;")?;
    let generated = fixture.0.join("generated");
    fs::create_dir_all(&generated)?;
    fs::write(generated.join("output.dcu"), "generated")?;
    std::os::unix::fs::symlink(fixture.0.join("source"), generated.join("source-link"))?;
    let dangling = fixture.0.join("dangling");
    std::os::unix::fs::symlink(fixture.0.join("missing"), &dangling)?;
    util::remove_generated([
        generated.clone(),
        dangling.clone(),
        fixture.0.join("absent"),
    ])?;
    assert!(!generated.exists());
    assert!(fs::symlink_metadata(dangling).is_err());
    assert_eq!(fs::read_to_string(kept)?, "unit Kept;");
    Ok(())
}

#[test]
fn progress_export_requires_verified_bytes_and_counts_entry_chunks() -> Result<()> {
    let fixture = Fixture::new("progress-report")?;
    fs::write(
        fixture.0.join("source/Example.pas"),
        r#"unit Example;
interface
procedure First; // @addr $1000
procedure Second; // @addr $1020
implementation
{ @routine $1000 First }
procedure First; begin end;
{ @end $1000 }
{ @routine $1020 Second }
procedure Second; begin end;
{ @end $1020 }
end.
"#,
    )?;
    let mut project = Project::open(&fixture.0)?;
    let digest = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
    project.settings["target"] = json!({"sha256": digest});
    fs::create_dir_all(fixture.0.join("reference"))?;
    let inventory_path = fixture.0.join("reference/native_ranges.json");
    let mut inventory = json!({"snapshot": {"sha256": digest}, "ranges": {
        "4096": {"chunks": [{"start":4096,"end":4112},{"start":8192,"end":8224}]},
        "4128": {"chunks": [{"start":4128,"end":4136},{"start":8192,"end":8224}]}
    }});
    fs::write(&inventory_path, serde_json::to_vec(&inventory)?)?;
    use rangers_tools::inspect::progress::generate;
    let report = generate(&project, b"abc")?;
    assert_eq!(report["version"], 2);
    assert_eq!(report["measures"]["total_code"], "24");
    assert_eq!(report["measures"]["matched_code"], "24");
    assert_eq!(report["measures"]["total_functions"], 2);
    assert_eq!(report["measures"]["total_units"], 1);
    assert_eq!(
        report["units"][0]["metadata"]["source_path"],
        "source/Example.pas"
    );
    assert!(generate(&project, b"abd").is_err());
    inventory["snapshot"]["sha256"] = json!("different build");
    fs::write(&inventory_path, serde_json::to_vec(&inventory)?)?;
    assert!(generate(&project, b"abc").is_err());
    Ok(())
}

#[test]
fn delphi7_method_pointer_alignment_preserves_natural_member_ordinals() -> Result<()> {
    let fixture = Fixture::new("delphi7-method-pointer-alignment")?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        "program Rangers; uses Callbacks; {$I RecoveredExports.inc} begin end.\n",
    )?;
    fs::write(
        fixture.0.join("source/Callbacks.pas"),
        r#"unit Callbacks; interface
 type
   TCallback = procedure of object;
   TRecord = record // @size $10
     Marker: Byte; // @offset $0
     Callback: TCallback; // @offset $8
   end;
   TControl = class // @size $18
     Marker: Cardinal; // @offset $4
     NextMarker: Cardinal; // @offset $8
     Callback: TCallback; // @offset $10
   end;
 var State: TRecord; // @addr $2000
     Control: TControl; // @addr $2010
 procedure Touch; // @addr $1000
 implementation
 { @routine $1000 Touch }
 procedure Touch; begin Inc(State.Marker); Inc(Control.Marker); end;
 { @end $1000 }
 end.
 "#,
    )?;
    let mut project = Project::open(&fixture.0)?;
    project.settings["compiler"]["natural_alignment"] = json!(true);
    project.settings["compiler"]["method_pointer_alignment"] = json!(8);
    let output = fixture.0.join("generated");
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let emitted = fs::read_to_string(output.join("Callbacks.pas"))?;
    assert!(!emitted.contains("Gap1:"));
    assert!(!emitted.contains("GapC:"));
    project.settings["compiler"]["method_pointer_alignment"] = json!(4);
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let emitted = fs::read_to_string(output.join("Callbacks.pas"))?;
    assert!(emitted.contains("Gap1:"));
    assert!(emitted.contains("GapC:"), "{emitted}");
    Ok(())
}

#[test]
fn default_indexed_property_retains_its_directive_and_implicit_accessor() -> Result<()> {
    let fixture = Fixture::new("default-indexed-property")?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        "program Rangers; uses Values; {$I RecoveredExports.inc} begin end.\n",
    )?;
    let source = r#"unit Values;
interface
type
  TValues = class // @size $04 @methodorder virtual
    function ReadAt(Index: Integer): Integer; // @addr $1000
    procedure WriteAt(Index: Integer; Value: Integer); // @addr $1004
    function ReadScalar: Integer; // @addr $100C
    property Entries[Index: Integer]: Integer read ReadAt write WriteAt; default;
    property UnusedValue: Integer read ReadScalar default 0;
  end;
function First(Value: TValues): Integer; // @addr $1008
implementation
{ @routine $1008 First }
function First(Value: TValues): Integer;
begin
  Value[0] := 7;
  Result := Value[0];
end;
{ @end $1008 }
end.
"#;
    let output = fixture.0.join("generated");
    for order in ["virtual", "source"] {
        fs::write(
            fixture.0.join("source/Values.pas"),
            source.replace("@methodorder virtual", &format!("@methodorder {order}")),
        )?;
        let mut project = Project::open(&fixture.0)?;
        let declaration = project.compiler.lookup("TValues")?;
        assert_eq!(declaration.data["properties"][0]["default_indexed"], true);
        assert!(
            declaration.data["properties"][1]
                .get("default_indexed")
                .is_none()
        );
        Emitter::new(&mut project)?.write_units(&output, true)?;
        let generated = fs::read_to_string(output.join("Values.pas"))?;
        assert!(
            generated.contains(
                "property Entries[Index: Integer]: Integer read ReadAt write WriteAt; default;"
            ),
            "{generated}"
        );
        assert!(generated.contains("function ReadAt(Index: Integer): Integer;"));
        assert!(generated.contains("procedure WriteAt(Index: Integer; Value: Integer);"));
        assert_eq!(generated.matches(" default;").count(), 1);
        assert!(generated.contains("Value[0] := 7;"));
    }
    Ok(())
}

#[test]
fn source_class_order_retains_properties_and_preserves_layout_and_slots() -> Result<()> {
    let fixture = Fixture::new("source-class-members")?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        "program Rangers; uses Shapes; {$I RecoveredExports.inc} begin end.\n",
    )?;
    fs::write(
        fixture.0.join("source/PropertyTypes.pas"),
        "unit PropertyTypes; interface type ZExternal = Integer; implementation end.\n",
    )?;
    let config = fixture.0.join("project.toml");
    fs::write(
        &config,
        fs::read_to_string(&config)? + "\n[compiler]\nnatural_alignment=false\n",
    )?;
    let source = r#"unit Shapes;
interface
uses PropertyTypes;
type
  ZCount = Integer;
  ZIndex = (ziFirst, ziLast); // @size $01
  TCountState = record // @size $04
    Value: Integer; // @offset $00
  end;
  TBase = class // @size $04
    function GetInherited: Integer; // @addr $1018
  end;
  TLayout = class(TBase) // @size $10 @methodorder source
  public
    Flag: Byte; // @offset $04
    procedure Before; // @addr $1000
    property DormantFlag: Byte read Flag;
    property DormantInherited: Integer read GetInherited;
    procedure First; virtual; // @addr $100C @slot $00
  public
    CountField: TCountState; // @offset $08
    property DormantCount: ZCount read CountField . Value;
    property DormantExternal: ZExternal read CountField.Value;
    function ReadIndexed(Index: ZIndex): Integer; // @addr $1008
    property DormantIndex[Index: ZIndex]: Integer read ReadIndexed;
    procedure Second; virtual; // @addr $1004 @slot $04
    procedure Last; virtual; // @addr $1010 @slot $08
  end;
procedure Use(Value: TLayout); // @addr $1014
implementation
{ @routine $1014 Use }
procedure Use(Value: TLayout);
begin Value.Before; Value.First; Value.Second; Value.Last; end;
{ @end $1014 }
end.
"#;
    fs::write(fixture.0.join("source/Shapes.pas"), source)?;
    let output = fixture.0.join("generated");
    let mut project = Project::open(&fixture.0)?;
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let generated = fs::read_to_string(output.join("Shapes.pas"))?;
    let interface = generated.split_once("implementation").unwrap().0;
    let at = |text: &str| interface.find(text).expect(text);
    // Unused property declarations must survive: they participate in D7 member
    // numbering. Its otherwise-unused accessor must also be declared.
    assert!(at("procedure Before;") < at("property DormantFlag:"));
    assert!(at("property DormantInherited:") < at("procedure First;"));
    assert!(at("procedure First;") < at("Gap5: array[0..2] of Byte;"));
    assert!(at("Gap5: array[0..2] of Byte;") < at("CountField: TCountState;"));
    assert!(at("CountField: TCountState;") < at("function ReadIndexed("));
    assert!(at("function ReadIndexed(") < at("property DormantIndex["));
    assert!(at("property DormantIndex[") < at("procedure Second;"));
    assert!(at("procedure Second;") < at("procedure Last;"));
    assert!(interface.contains("GapC: array[0..3] of Byte;"));
    // Class forward declarations precede all complete definitions; only the
    // complete class declaration needs these property/accessor types available.
    assert!(at("ZIndex =") < at("TLayout = class(TBase)"));
    assert!(at("ZCount =") < at("TLayout = class(TBase)"));
    assert!(interface.contains("function GetInherited:"));
    assert!(interface.contains("PropertyTypes"));
    assert!(fs::read_to_string(output.join("PropertyTypes.pas"))?.contains("ZExternal = Integer;"));
    // Delphi requires a new visibility section before fields after methods.
    let between = &interface[at("property DormantFlag:")..at("CountField:")];
    assert!(between.contains("public"));
    // The default/explicit virtual-order path retains its existing pruning.
    fs::write(
        fixture.0.join("source/Shapes.pas"),
        source.replace("@methodorder source", "@methodorder virtual"),
    )?;
    let mut project = Project::open(&fixture.0)?;
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let generated = fs::read_to_string(output.join("Shapes.pas"))?;
    let interface = generated.split_once("implementation").unwrap().0;
    assert!(!interface.contains("property Dormant"));
    assert!(!interface.contains("function ReadIndexed("));
    assert!(interface.find("CountField:").unwrap() < interface.find("procedure First;").unwrap());
    Ok(())
}

#[test]
fn addressed_local_constants_keep_storage_without_being_hoisted() -> Result<()> {
    let fixture = Fixture::new("local-constant-storage")?;
    fs::write(
        fixture.0.join("source/Rangers.dpr"),
        "program Rangers; uses Values; {$I RecoveredExports.inc} begin end.\n",
    )?;
    fs::write(
        fixture.0.join("source/Values.pas"),
        "unit Values; interface\nfunction Lookup(Index: Integer): Integer; // @addr $1000\n\
         implementation\n{ @routine $1000 Lookup }\n\
         function Lookup(Index: Integer): Integer;\n\
         const Table: array[0..1] of Integer = (10, 20); // @addr $2000\n\
         begin Result := Table[Index]; end;\n{ @end $1000 }\nend.\n",
    )?;
    let mut project = Project::open(&fixture.0)?;
    let manifest = project.compiler.build()?;
    let globals = manifest["globals"].as_array().unwrap();
    assert_eq!(globals.len(), 1);
    assert_eq!(globals[0]["addr"], 0x2000);
    assert_eq!(globals[0]["size"], 8);
    let output = fixture.0.join("generated");
    Emitter::new(&mut project)?.write_units(&output, true)?;
    let generated = fs::read_to_string(output.join("Values.pas"))?;
    assert_eq!(generated.matches("Table: array").count(), 1);
    assert!(
        !generated
            .split_once("implementation")
            .unwrap()
            .0
            .contains("Table:")
    );
    assert!(generated.contains("Result := Table[Index]"));
    Ok(())
}
