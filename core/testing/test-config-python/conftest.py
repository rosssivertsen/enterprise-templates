"""Shared test fixtures for all tests."""
import pytest

@pytest.fixture
def sample_config():
    """Provide a sample configuration for testing."""
    return {
        "testing": True,
        "environment": "test",
    }
