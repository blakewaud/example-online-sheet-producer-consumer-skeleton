import shutil
from RPA.Tables import Tables, Table
from pathlib import Path

ROOT = Path(__file__).parent
MOCK_FILE = ROOT / "devdata" / "original_mock.csv"


class MockSheetProvider:
    """A mock class that has a get_sheet_as_table method that returns a mock table."""

    def get_sheet_as_table(self, sheet_id: str) -> Table:
        """Returns a mock table."""
        shutil.copy(MOCK_FILE, "mock.csv")
        table = Tables().read_table_from_csv("mock.csv", True)
        return table

    def update_row(self, row: dict, sheet_id: str) -> None:
        """Updates a row in a mock table."""
        table = Tables().read_table_from_csv("mock.csv", True)
        table.set_row(row["ROW_ID"], row)
        Tables().write_table_to_csv(table, "mock.csv", True)
