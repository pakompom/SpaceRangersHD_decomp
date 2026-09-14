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
  function AddOffset(Number: Integer): Integer; // @addr $1010 @ida "int __usercall $name@<eax>(int Number@<eax>, void *ParentFrame@<^0>);"
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
    assert!(
        nested.meta["ida"]
            .as_str()
            .unwrap()
            .contains("ParentFrame@<^0>")
    );
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
        "unit System; interface\ntype TObject = class // @size $04\nend;\nimplementation end.\n",
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
