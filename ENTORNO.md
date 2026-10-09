# Entorno del ejercicio

## Interfaz elegida

JupyterLab local, abierto en el navegador. Reúne notebooks, explorador de archivos y editor de texto. La ventaja es una interfaz centrada en notebooks sin configurar otro IDE; no se presupone un menor consumo de memoria que VS Code.

Si prefieres VS Code, también puedes utilizarlo: seleccionar `.venv/Scripts/python.exe` como intérprete y entorno del kernel.

## Abrir y cerrar

Hacer doble clic en `iniciar-jupyter.cmd`. Se abre el navegador y una consola que mantiene el servidor activo. Seleccionar el kernel **Python (rag-demo)**. Cerrar la pestaña no apaga el servidor: usar Ctrl+C en la consola y confirmar si se solicita.

El lanzador limita el servidor a esta computadora (127.0.0.1), conserva la autenticación predeterminada y guarda configuración y archivos de Jupyter dentro del proyecto. No requiere activar el entorno ni cambiar la política de ejecución de PowerShell.

## Componentes

- Python 3.12, con entorno aislado `.venv` creado por cada alumno.
- JupyterLab e ipykernel para notebooks.
- NumPy para operaciones vectoriales posteriores.
- PyYAML para metadatos y evaluación.
- python-dotenv para configuración local futura.
- Pydantic para contratos de datos posteriores.
- SDK oficial `openai` para consultar el LLM mediante Responses API.

`requirements.in` expresa las dependencias directas; `requirements.txt` fija todas las versiones instaladas en Windows con Python 3.12.9. No copiar `.venv` a otra computadora: recrearla. Haystack está instalado para el notebook 06. Los embeddings usan Sentence Transformers en CPU con el modelo multilingüe E5 small, almacenado dentro de `.cache/huggingface/`. La instalación no consume la API; ejecutar consultas del notebook sí tiene costo por uso.

## Primera consulta sin RAG

Abrir `notebooks/01_modelo_sin_rag.ipynb` y ejecutar en orden. Lee `OPENAI_API_KEY` de `.env` sin imprimirla. `.env.example` muestra el formato sin secretos; no reemplazar el `.env` existente. El modelo predeterminado es `gpt-4.1-mini-2025-04-14`; se puede configurar `OPENAI_MODEL` en `.env`. Después de cambiarlo, volver a ejecutar la configuración.

El notebook realiza una sola consulta al ejecutar su celda de API; Q09 queda como alternativa manual. No envía corpus, archivos ni respuestas esperadas. Si aparece HTTP 401, revisar la clave; 403/404, permisos o modelo; 429, saldo/cuota o límites. Los mensajes de error omiten cuerpos de respuesta para evitar mostrar datos sensibles.

Verificación del 2026-10-08: las celdas se ejecutaron secuencialmente contra la API con Q01. La respuesta terminó correctamente y reconoció que faltaba la política interna; consumió 116 tokens de entrada y 45 de salida. El notebook se entrega sin salidas guardadas para ejecutarlo en clase. Las dependencias también pasaron `pip check`.

## Reproducir la instalación

Instala Python 3.12 y comprueba `python --version`. Desde la carpeta descargada o clonada, crea un entorno propio:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m ipykernel install --sys-prefix --name rag-demo --display-name "Python (rag-demo)"
```

Después, copia `.env.example` a `.env` y edita esa copia para colocar tu propia API key. Nunca publiques `.env`. Abre Jupyter con `iniciar-jupyter.cmd` y ejecuta los siete notebooks en orden. No necesitas copiar `data/` ni resultados previos: los generarás durante el ejercicio.

`.python-version` sirve para quienes usan pyenv; no instala Python automáticamente. `requirements.txt` refleja la instalación probada en Windows con Python 3.12.9.

## Verificación realizada

Se comprobó la compatibilidad de dependencias con `pip check`, la importación de las bibliotecas, la ejecución de una celda con el kernel del proyecto y la lectura de seis documentos y diez casos YAML. También se inició un servidor de prueba y se obtuvo HTTP 200 de la interfaz de JupyterLab; ese servidor se cerró después de la prueba. La apertura visual mediante doble clic queda para el uso interactivo del usuario.

## Recuperación local

Abrir `notebooks/03_embeddings_y_retrieval.ipynb`. Sus dependencias se instalaron exclusivamente en `.venv`. No necesita la API key. El modelo se descarga una vez y después se reutiliza localmente. Una advertencia sobre symlinks en Windows solo indica que la caché puede usar más disco; no exige ejecutar como administrador. Reiniciar el kernel si estaba abierto durante la instalación.

## Generación con evidencia

Abrir `notebooks/04_rag_completo.ipynb`. No requiere nuevas dependencias. Reutiliza los datos y el modelo local del notebook 03, y la configuración de OpenAI del notebook 01. La celda de generación consume API; la comparación opcional está desactivada. Las trazas de `runs/` conservan prompts y respuestas, sin la clave.

## Barras de progreso en Jupyter

Se incluye ipywidgets para las barras de tqdm dentro de notebooks. Si Jupyter estaba abierto al instalarlo, guardar el trabajo, cerrar el servidor, volver a abrir iniciar-jupyter.cmd y reiniciar el kernel. Esto resuelve la dependencia IProgress; no requiere cambiar el código de RAG ni actualizar todo Jupyter.


## Pipeline con Haystack

Abrir `notebooks/06_rag_con_haystack.ipynb` y usar Python (rag-demo). Haystack se instaló en el mismo virtualenv; no se requieren servicios externos de almacenamiento. Reiniciar el kernel si estaba abierto durante la instalación. La preparación es local; la sección de generación hace una llamada a OpenAI cuando `EJECUTAR_LLM` está activado. Los componentes propios conservan el modelo de embeddings y la llamada Responses API del paso anterior.

## Último notebook: mejoras

`notebooks/07_mejoras_y_comparacion.ipynb` utiliza Haystack, NumPy y Pydantic ya instalados. Lee tu evaluación del notebook 05 y ejecuta veinte consultas por defecto. Después de generar tus resultados, `EJECUTAR_API=False` permite revisarlos sin nuevas llamadas. Los experimentos de recuperación son locales. Las claves no se guardan en los resultados.
