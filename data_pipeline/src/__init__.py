# Auto-import container compatibility when src module is imported
try:
    from .utils import container_compat
except ImportError:
    pass