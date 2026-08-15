import gzip
from importlib.metadata import version
from time import monotonic

import idna
import pytest
from httplib2.decode import DecodeRatioError, LimitDecoder, ZlibDecoder
from packaging.version import Version
from pyasn1.codec.ber import decoder
from pyasn1.error import PyAsn1Error


@pytest.mark.parametrize(
    ("package", "minimum"),
    [
        ("httplib2", "0.32.0"),
        ("idna", "3.15"),
        ("pyasn1", "0.6.4"),
    ],
)
def test_vulnerable_transitive_packages_are_patched(package, minimum):
    assert Version(version(package)) >= Version(minimum)


def test_httplib2_rejects_a_high_ratio_compressed_response():
    compressed = gzip.compress(b"A" * (512 * 1024))
    decoder_with_limits = LimitDecoder(
        ZlibDecoder(), ratio=10, safe_limit=1024, hard_limit=2 * 1024 * 1024
    )

    with pytest.raises(DecodeRatioError):
        decoder_with_limits.consume_bytes(compressed, chunk_size=0)


def test_pyasn1_rejects_an_unbounded_long_form_tag_quickly():
    malicious_tag = b"\x1f" + (b"\x81" * 20_000) + b"\x00\x00"
    started = monotonic()

    with pytest.raises(PyAsn1Error, match="Tag ID octet count exceeds limit"):
        decoder.decode(malicious_tag)

    assert monotonic() - started < 1


def test_idna_accepts_a_valid_name_and_rejects_invalid_joiner_input():
    assert idna.encode("münich.example") == b"xn--mnich-kva.example"

    with pytest.raises(idna.IDNAError):
        idna.encode("a\u200db.example")
