from backend.cli import main


def test_cli_main(capsys):
    assert main() == 0
    captured = capsys.readouterr()
    assert "coulisses-cli: OK" in captured.out
