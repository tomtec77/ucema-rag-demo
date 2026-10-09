# Demo RAG — políticas internas de Andes Retail

Material ficticio para Analítica de Negocios Avanzada, UCEMA 2026, T07. Continúa el enfoque acordado en «Diseño de demo RAG»: hacer visibles recuperación, contexto, grounding, citas y abstención. La alineación se basa en esa conversación; el PDF de T07 no está incluido aquí.

La empresa, los montos y las reglas son inventados. El objetivo es que la respuesta dependa de evidencia recuperada. Un modelo sin el corpus puede abstenerse correctamente o acertar por casualidad: un acierto aislado no demuestra conocimiento de la empresa.

## Comenzar desde cero

Este repositorio contiene las fuentes del ejercicio, no ejecuciones resueltas. Prepara el entorno siguiendo [ENTORNO.md](ENTORNO.md), configura tu propia clave en `.env` y ejecuta los notebooks **01 a 07 en orden**, de arriba abajo. En cada notebook utiliza un kernel nuevo o reinícialo antes de ejecutar todas sus celdas.

| Notebook | Resultado que produces |
|---|---|
| 01 | Respuesta sin documentos |
| 02 | Chunks y manifiesto en `data/` |
| 03 | Embeddings, manifiesto y ejemplos de recuperación en `data/` |
| 04 | Respuesta con evidencia y traza en `runs/` |
| 05 | Diez respuestas, métricas y fichas para completar en `eval/results/` |
| 06 | Comprobación de equivalencia de Haystack y respuesta con su pipeline |
| 07 | Comparación de búsquedas y veinte respuestas nuevas en `eval/improvements/` |

Los notebooks 01, 04 y 06 hacen una llamada cada uno por defecto; el 05 hace diez y el 07 veinte: **33 llamadas** para una ejecución completa, sin repeticiones ni opciones adicionales. Cada ejecución de esas celdas consume API. Los notebooks 02 y 03 no usan OpenAI; el 03 descarga el modelo de embeddings la primera vez.

`data/`, `runs/`, `eval/results/` y `eval/improvements/` se crean localmente y están excluidos de Git. No copies resultados de otra persona. Las fichas de revisión semántica se generan sin completar: evalúa tus respuestas con la rúbrica y redacta tus conclusiones. El notebook 07 lee la última evaluación creada en el 05, sin nombres de ejecuciones predefinidos.

## Archivos

```text
rag-demo/
├── corpus/
│   ├── 01_politica_global_viajes_v4.md
│   ├── 02_anexo_argentina_v2.md
│   ├── 03_politica_global_viajes_v2_expirada.md
│   ├── 04_politica_gastos_generales_v3.md
│   ├── 05_politica_tarjetas_corporativas_v1.md
│   └── 06_faq_viajes.md
├── eval/
│   ├── preguntas.md
│   └── expected_results.yaml
└── README.md
```

Los archivos son UTF-8. Para preparar tu entorno local de JupyterLab, consultar [ENTORNO.md](ENTORNO.md) para abrirlo o reproducir la instalación. Está implementado el circuito mínimo completo: consulta base, preparación, recuperación y generación con evidencia. La evaluación inicial está disponible en el notebook 05. Indexar después **solo `corpus/`**: incluir las preguntas, respuestas esperadas o este README filtraría la solución al sistema.

## Primer notebook disponible

Los notebooks incluyen explicaciones antes y después de cada bloque de código: propósito, sintaxis relevante, decisiones de diseño, resultado esperado y límites de lo comprobado. Ejecutar de arriba abajo y detenerse a inspeccionar las salidas. Para los próximos notebooks se mantendrá este nivel de explicación, pensado como material de clase y de lectura autónoma.

`notebooks/01_modelo_sin_rag.ipynb` implementa la consulta inicial sin documentos. Abrirlo desde JupyterLab y usar el kernel Python (rag-demo). Configuración y credenciales: [ENTORNO.md](ENTORNO.md). Esta etapa permite observar respuestas sin grounding antes de agregar recuperación.

## Lectura y división disponibles

`notebooks/02_preparar_documentos.ipynb` implementa el paso 4, sin API ni dependencias nuevas. Ejecutar sus celdas en orden con Python (rag-demo). Lee exclusivamente `corpus/*.md`, valida metadatos YAML y divide por encabezados de sección. Produce **17 chunks de los seis documentos actuales**.

Cada chunk conserva fuente, metadatos, sección original e introducción. La sección A2 incorpora A1 como contexto explícito para mantener las condiciones de la excepción argentina. `retrieval_text` combina estos elementos para la próxima etapa; `text` conserva la sección original sin modificaciones. Se muestran tres ejemplos completos y se comprueba que la división permite reconstruir el cuerpo de cada documento.

La última celda genera `data/chunks.jsonl` y `data/manifest.json`, con huellas de las fuentes y descripción de la estrategia. Regenerarlos después de modificar el corpus; no indexar estos archivos como si fueran documentos adicionales. No hay límite automático de tokens: la estrategia está pensada para estas secciones breves. Aún no se calculan embeddings ni se realiza búsqueda.

## Embeddings y recuperación

`notebooks/03_embeddings_y_retrieval.ipynb` desarrolla el paso 5 con explicaciones antes de cada bloque: carga y comprobación de fuentes, modelo local, medición de tokens, embeddings normalizados, similitud coseno con NumPy, top-k e inspección de evidencia. Permite comparar preguntas y k = 1, 3 y 5 sin generar respuestas.

Usa `intfloat/multilingual-e5-small` con revisión fija, CPU y caché dentro de `.cache/`. La primera carga requiere descargar el modelo; no se envía el corpus ni se usa la API de OpenAI. Instala las dependencias en tu propio virtualenv utilizando `requirements.txt`.

El texto de embedding omite las claves administrativas del YAML y conserva título, audiencia, introducción, contexto y sección. Los chunks originales siguen completos. Se rechazan entradas demasiado largas para evitar truncamiento silencioso.

Genera `data/embeddings.npy`, `data/embeddings_manifest.json` y `data/retrieval_examples.json`. El manifiesto conserva IDs ordenados, modelo, revisión, textos usados y huella del JSONL. Regenerar después de cambiar corpus o configuración. Las puntuaciones no representan probabilidades ni autoridad; el recuperador todavía no decide abstención.

## RAG completo

`notebooks/04_rag_completo.ipynb` implementa el paso 6 con explicaciones detalladas de cada bloque. Carga el índice existente, verifica huellas y orden de filas, recupera top-k y muestra el prompt completo antes de llamar al LLM. No modifica el recuperador ni incorpora respuestas esperadas.

Usa OpenAI con la clave local y envía solo la pregunta, el contexto común y los fragmentos ficticios seleccionados. Ejecutar todas las celdas realiza **una llamada**, Q01 con k = 3 por defecto. Para otro caso, cambiar `CASO`/`K` y ejecutar desde la sección 3. La comparación controlada sin documentos es opcional y hace una llamada adicional con idénticas instrucciones.

Pide estado, respuesta, citas e información faltante como JSON. Valida formato e IDs, sin confundir esa comprobación con respaldo semántico. La distinción entre falta de evidencia en top-k y ausencia en todo el corpus está explicada. `runs/` guarda trazas locales sin credenciales y queda excluido de Git. Todavía no usamos Pydantic ni respuesta estructurada forzada por la API.

## Evaluación del RAG

`notebooks/05_evaluacion_rag.ipynb` mide los diez casos manteniendo el recuperador, prompt y modelo del paso 6. Calcula cobertura documental a k = 1, 3 y 5, coincidencia de estados y validez local de formato/citas; la revisión semántica se registra por cada hecho y uso prohibido.

Por defecto `EJECUTAR_API=True` genera diez consultas nuevas con costo, conservando cada respuesta y cualquier error. Después puedes usar `False` para volver a analizar tu propia ejecución sin llamadas. `eval/results/latest.json` identifica la corrida más reciente. Las carpetas de corridas contienen configuración, prompts, resultados, métricas automáticas y fichas semánticas; no contienen credenciales.

Q08 se excluye del promedio de cobertura porque no tiene documentos relevantes. Los errores técnicos siguen en el denominador de diez casos de las métricas de generación. Una cita válida por ID no implica respaldo de la afirmación; por eso no se presenta el resultado automático como calidad semántica total.

## El mismo RAG con Haystack

`notebooks/06_rag_con_haystack.ipynb` implementa el paso 8. Explica la correspondencia entre las funciones anteriores y `Document`, `InMemoryDocumentStore`, `DocumentWriter`, `InMemoryEmbeddingRetriever`, `PromptBuilder` y `Pipeline`.

Reutiliza la matriz y el modelo local. Incluye adaptadores explícitos para codificar consultas, serializar fuentes y llamar a Responses API con la misma configuración. No es un pipeline compuesto exclusivamente por componentes prefabricados: esa decisión conserva el experimento y muestra cómo incorporar código propio.

La preparación se puede inspeccionar sin llamar al LLM. La sección 8 realiza una llamada por ejecución; `EJECUTAR_LLM = False` permite omitirla. Para cambiar pregunta o k, ejecutar desde la sección 5. Las credenciales se leen de `.env` y no se guardan en trazas. Los notebooks anteriores no se modificaron para esta transición.

`data/haystack_equivalence.json` conserva la comparación; `runs/haystack_*.json` guarda la traza de generación. Haystack 3.3.0 quedó instalado solo en `.venv`, con versiones fijadas en `requirements.txt`.

## Mejoras y comparación controlada

`notebooks/07_mejoras_y_comparacion.ipynb` completa el paso 9: compara dense, BM25 y fusión RRF sobre los mismos textos; muestra el costo de filtrar documentos históricos; y contrasta respuestas estructuradas con Pydantic y nuevas instrucciones de abstención.

Las pruebas de generación conservan literalmente el contexto de la corrida original. Primero cambia solo el formato, después las instrucciones manteniendo el esquema. Las variantes de búsqueda y filtros no se mezclan en esas llamadas; no se afirma haber evaluado su efecto combinado.

Por defecto `EJECUTAR_API=True` realiza veinte consultas nuevas (dos variantes por diez preguntas), usando la última evaluación propia del notebook 05 como referencia. Después puedes usar `False` para analizar tus resultados sin llamadas; si cambias la evaluación base, debes generar una comparación nueva. No requiere dependencias nuevas. `eval/improvements/` conserva configuración, entradas, respuestas, métricas y fichas de revisión; la evaluación base permanece intacta.

## Reglas de la simulación

Usar como fecha de consulta fija **2026-10-08**, aunque la demo se ejecute otro día. Las preguntas tratan viajes finalizados en 2026 salvo indicación contraria. `vigente_hasta: null` significa sin fecha de fin establecida en este corpus, no una promesa de vigencia perpetua. Las fechas límite de vigencia son inclusivas.

La política global fija 60 días corridos desde el fin del viaje. El anexo argentino conserva ese plazo y permite, bajo condiciones, taxis sin comprobante hasta ARS 18.000 por traslado. El país de contratación y el lugar del taxi son condiciones distintas. Los 30 días de gastos generales y los 10 días de conciliación de tarjeta corresponden a otros trámites.

La política archivada conserva el antiguo plazo de 30 días desde la compra. La FAQ contiene **deliberadamente un dato incorrecto de 45 días**: permanece publicada, pero tiene menor autoridad. No corregir ese dato al preparar la demo. La precedencia está declarada en los documentos: anexo aplicable en sus excepciones, política global para el resto y FAQ como orientación. La fecha más reciente no decide por sí sola la autoridad.

## Secuencia pedagógica sugerida

1. Preguntar Q01 y Q09 al modelo sin documentos y observar si inventa o reconoce el límite.
2. Leer los seis documentos; separar preparación del corpus de atención de consultas.
3. Dividir por secciones, conservando juntas reglas y condiciones. Adjuntar a cada chunk `document_id`, título, versión, estado, vigencia, jurisdicción, audiencia, autoridad, sección y archivo fuente. No separar la excepción de su ámbito de aplicación.
4. Mostrar recuperación sin generación: consulta, top-k, fragmentos y scores. Probar k = 1, 3 y 5. Inspeccionar si esos fragmentos bastan para responder antes de llamar al modelo.
5. Construir el contexto y pedir respuesta con estado, hechos sustentados y citas por documento/sección. El score de similitud no equivale a autoridad ni a probabilidad de que la respuesta sea correcta.
6. Evaluar por separado retrieval y generación. Más adelante, organizar el mismo flujo mínimo en componentes de Haystack, sin cambiar corpus ni preguntas.

BM25 y embeddings pueden compararse con Q01/Q02; no se garantiza que dense gane en este corpus pequeño. Mantener iguales chunks y k al comparar. Empezar con todos los documentos permite observar contaminación; luego incorporar filtros de vigencia y alcance. En Q03 conviene recuperar el archivo histórico para explicar la regla citada, identificándolo como evidencia histórica. Un filtro que borre todos los documentos viejos perdería esa explicación.

## Qué enseña cada caso

| Caso | Retrieval | Grounding y abstención | Evaluación |
|---|---|---|---|
| Q01 | Recuperar V1 frente a plazos parecidos | Respetar cantidad, unidad y fecha inicial | Hechos y fuente correctos |
| Q02 | Comparar búsqueda léxica y semántica | Distinguir solicitud de devolución y fecha de pago | Consistencia con Q01 |
| Q03 | Hallar versión actual e histórica | Explicar la anterior sin aplicarla | Uso correcto de vigencia |
| Q04 | Recuperar global y anexo | No inventar diferencias por país | Alcance y plazo conservado |
| Q05 | Recuperar excepción y condiciones | Responder condicionalmente, sin prometer aprobación | Monto, audiencia, lugar y documentación |
| Q06 | Recuperar fuentes contradictorias | Resolver por autoridad explícita | Elegir 60 y justificar descarte de 45 |
| Q07 | Priorizar tarjetas pese a «viaje» | Sustentar las acciones en T2 | Resistencia a ruido temático |
| Q08 | Aceptar que no hay respuesta relevante | Abstenerse sin inventar ni inferir 0 % | `no_answer`; no puntuar recall |
| Q09 | Recuperar la regla aunque falte un dato | Pedir fecha de fin; no decidir sí/no | `insufficient_evidence` y aclaración útil |
| Q10 | Cubrir tres trámites posibles | Exponer alternativas y pedir precisión | Cobertura y ambigüedad reconocida |

## Contrato de evaluación

`preguntas.md` contiene las consultas; `expected_results.yaml` contiene la rúbrica docente enlazada por ID. `relevant_documents` usa los `document_id` del front matter y representa el conjunto necesario para la respuesta completa esperada. `irrelevant_documents` enumera distractores seleccionados, no necesariamente todos los restantes. `required_facts` se evalúa por significado. `must_not_use` prohíbe inferencias o usos de reglas, no la mera mención de un documento: en Q03 es correcto citar V2 para rechazar su aplicación actual.

Estados esperados:

- `answered`: la evidencia permite responder la pregunta, con las condiciones pertinentes.
- `no_answer`: el corpus no contiene la regla solicitada; pedir más datos personales no resolvería la ausencia.
- `insufficient_evidence`: existen reglas pertinentes, pero faltan datos de la consulta para elegir o aplicar una.

Para retrieval, registrar top-k de chunks y sus documentos. Calcular cobertura documental como documentos relevantes distintos recuperados / documentos relevantes esperados; los chunks repetidos no suman cobertura. Inspeccionar además que las secciones recuperadas contengan la evidencia: recuperar cualquier fragmento del archivo correcto no basta. Para Q08, la cobertura no aplica y se observa si el sistema fuerza una respuesta con distractores. Una cita a G3 puede delimitar el alcance, pero no acredita un porcentaje odontológico.

Para generación, registrar estado correcto, cumplimiento de cada hecho requerido, ausencia de usos prohibidos y citas que realmente respalden las afirmaciones. En Q08 no exigir una cita que simule probar la inexistencia de un beneficio. En Q09/Q10 evaluar también la pregunta aclaratoria. Una respuesta acertada sin evidencia puede fallar grounding; una abstención innecesaria en Q01 puede fallar utilidad.

Estos diez casos son una evaluación didáctica pequeña, no un benchmark ni una estimación estadística de calidad. Una vez implementado el flujo, añadir preguntas reservadas y variaciones de límites (día 60/61, ARS 18.000/18.001, país de contratación distinto) permitirá comprobar generalización sin ajustar todo a estas diez consultas.
