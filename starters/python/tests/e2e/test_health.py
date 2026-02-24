"""E2E test — validates health endpoint against a running instance."""
import os
import pytest
import requests

BASE_URL = os.getenv("E2E_BASE_URL", "http://localhost:8000")

@pytest.mark.e2e
def test_health_endpoint_live():
    response = requests.get(f"{BASE_URL}/health", timeout=10)
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
