# simple_fastapi

API de la sesión 2. Tres rutas y las pruebas que comprueban lo que responden.

Desde esta carpeta:

```bash
uv sync --locked
uv run --with pytest pytest
```

| Método | Ruta | Respuesta |
|---|---|---|
| `GET` | `/` | `{"Hello": "Grupo Estud-IA"}` |
| `GET` | `/items/{item_id}` | el id y el query `q`, si viene |
| `GET` | `/dummy` | el parámetro `a` y un saludo fijo |

`function.py` queda fuera de esas rutas. Los tests de `dummy_function` viven en `tests/`. El workflow de CI usa esta carpeta: `uv sync --locked` para el build y `uv audit --locked` para la auditoría.
