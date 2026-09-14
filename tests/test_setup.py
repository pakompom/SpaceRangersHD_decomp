"""Controls for recovered installer decoding and input integrity."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("decomp_setup", Path(__file__).resolve().parents[1] / "toolchain/setup.py")
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class InstallerInputs(unittest.TestCase):
    def test_password_from_original_installer_table(self):
        self.assertEqual(setup.decode_media_password(b"16D75160=>9??87;%%!%V#"), "qOApuCSIEck")

    def test_malformed_password_is_rejected(self):
        for encoded in (b"1", b"zz"):
            with self.subTest(encoded=encoded), self.assertRaises(ValueError):
                setup.decode_media_password(encoded)

    def test_input_mismatch_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "DCC32.EXE"
            path.write_bytes(b"abc")
            digest = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
            self.assertEqual(setup.checked(path, digest), path)
            path.write_bytes(b"abd")
            with self.assertRaisesRegex(RuntimeError, "Input checksum failed"):
                setup.checked(path, digest)
