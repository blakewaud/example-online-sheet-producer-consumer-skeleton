import shutil
from RPA.Tables import Tables, Table
from pathlib import Path

ROOT = Path(__file__).parent
MOCK_FILE = ROOT / "devdata" / "original_mock.csv"


class MockSheetProvider:
    """A mock class that has a get_sheet_as_table method that returns a mock table."""

    def __init__(self) -> None:
        self._table = None

    def get_sheet_as_table(self, sheet_id: str) -> Table:
        """Returns a mock table."""
        shutil.copy(MOCK_FILE, "mock.csv")
        table = Tables().read_table_from_csv("mock.csv", True, encoding="utf-8-sig")
        self._table = table
        return table

    def update_row(self, row_id: int, row: dict, sheet_id: str) -> None:
        """Updates a row in a mock table."""
        self._table.set_row(row_id - 1, row)
        self.save()

    def save(self) -> None:
        """Saves the mock table to a file."""
        if self._table is None:
            raise ValueError("No table to save")
        Tables().write_table_to_csv(self._table, "mock.csv", True, encoding="utf-8-sig")
