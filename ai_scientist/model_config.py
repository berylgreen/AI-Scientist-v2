"""
Centralized model configuration.

All model fallback defaults read from here.
To change the default model, set the DEFAULT_MODEL environment variable
(configured in .env file).
"""
import os

DEFAULT_MODEL = os.environ.get("DEFAULT_MODEL", "gpt-5.5")
DEFAULT_VLM_MODEL = os.environ.get("DEFAULT_VLM_MODEL", "gpt-image-2")
