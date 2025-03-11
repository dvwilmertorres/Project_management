import os
import subprocess
import sys

# Intentar importar openpyxl, si no está instalado, lo instala
try:
    import openpyxl
except ImportError:
    print("openpyxl no está instalado. Instalando...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "openpyxl"])

def create_project_structure(project_name):
    # Reemplazar espacios y guiones por guiones bajos y agregar "_mldti" al final
    project_name = project_name.replace(" ", "_").replace("-", "_")

    # Define the main directories that need to be created
    directories = [
        f"{project_name}/1.doc", 
        f"{project_name}/2.comms", 
        f"{project_name}/3.src",  
        f"{project_name}/4.reports",
        f"{project_name}/5.resources",  # Esta es la carpeta donde se creará el archivo Excel
    ]

    # Define subdirectories under doc, comms, and reports
    doc_subdirectories = [
        "architecture", "gantt"  # Puedes agregar más módulos según necesites
    ]
    coms_subdirectories = [
        "meeting_minutes", "progress_reports", "presentations"  # Puedes agregar más módulos según necesites
    ]
    reports_subdirectories = [
        "quality_reports", "risk_reports", "presentations"  # Puedes agregar más módulos según necesites
    ]

    # Create the main directories
    for directory in directories:
        os.makedirs(directory, exist_ok=True)

    # Create subdirectories under doc
    for subdir in doc_subdirectories:
        os.makedirs(f"{project_name}/1.doc/{subdir}", exist_ok=True)

    # Create subdirectories under comms
    for subdir in coms_subdirectories:
        os.makedirs(f"{project_name}/2.comms/{subdir}", exist_ok=True)

    # Create subdirectories under reports
    for subdir in reports_subdirectories:
        os.makedirs(f"{project_name}/4.reports/{subdir}", exist_ok=True)

    # Create the Excel file in the resources folder
    excel_path = f"{project_name}/5.resources/Resources.xlsx"
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Resources"

    # Agregar algunas celdas iniciales para el archivo Excel
    ws['A1'] = "Resource Name"
    ws['B1'] = "Resource Type"
    ws['C1'] = "Description"
    ws['D1'] = "Quantity"
    
    # Guarda el archivo Excel
    wb.save(excel_path)

    # Create README.md and .gitignore files with utf-8 encoding
    with open(f"{project_name}/README.md", 'w', encoding='utf-8') as readme_file:
        readme_file.write(f"# {project_name}\n\n")
        readme_file.write("## Descripción del Proyecto\n")
        readme_file.write("Este proyecto tiene como objetivo [breve descripción del objetivo y propósito del proyecto].\n")
        readme_file.write("\n## Objetivos\n")
        readme_file.write("- [Objetivo 1]\n")
        readme_file.write("- [Objetivo 2]\n")
        readme_file.write("\n## Alcance\n")
        readme_file.write("Este proyecto abarca los siguientes aspectos...\n")
        readme_file.write("\n## Estructura del Proyecto\n")
        readme_file.write("La estructura del proyecto está organizada de la siguiente manera:\n")
        readme_file.write("```\n")
        readme_file.write(f"{project_name}/\n")
        readme_file.write("├── 1.doc/\n")
        readme_file.write("│   ├── architecture/ \n" )
        readme_file.write("│   ├── gantt/\n")
        readme_file.write("│   └── modulo3/\n")
        readme_file.write("├── 2.comms/\n")
        readme_file.write("│   ├── meeting_minutes/\n")
        readme_file.write("│   ├── progress_reports/\n")
        readme_file.write("│   └── presentations/\n")
        readme_file.write("├── 3.src/\n")
        readme_file.write("└── 4.reports/\n")
        readme_file.write("    ├── quality_reports/\n")
        readme_file.write("    ├── risk_reports/\n")
        readme_file.write("    └── presentations/\n")
        readme_file.write("```\n")
        readme_file.write("\n## Metodología de Gestión de Proyectos\n")
        readme_file.write("Este proyecto sigue la metodología de [Scrum/Agile/Waterfall] para la gestión de tareas y entrega de resultados.\n")
        readme_file.write("\n## Roles y Responsabilidades\n")
        readme_file.write("Los roles clave en este proyecto son:\n")
        readme_file.write("- **Gestor de Proyecto**: Responsable de la planificación, ejecución y seguimiento del proyecto.\n")
        readme_file.write("- **Equipo de Desarrollo**: Encargados de la implementación técnica de los entregables.\n")
        readme_file.write("- **Stakeholders**: Personas o grupos que tienen interés en el proyecto y que brindan retroalimentación.\n")
        readme_file.write("\n## Entregables y Fechas Clave\n")
        readme_file.write("El proyecto tiene los siguientes entregables:\n")
        readme_file.write("- **Entrega 1**: [Descripción del entregable] - [Fecha]\n")
        readme_file.write("- **Entrega 2**: [Descripción del entregable] - [Fecha]\n")
        readme_file.write("\n## Gestión de Riesgos\n")
        readme_file.write("Durante el ciclo de vida del proyecto, se gestionarán los siguientes riesgos:\n")
        readme_file.write("- [Riesgo 1] y su plan de mitigación.\n")
        readme_file.write("- [Riesgo 2] y su plan de mitigación.\n")
        readme_file.write("\n## Gestión de Cambios\n")
        readme_file.write("Cualquier solicitud de cambio será evaluada y gestionada a través del proceso de control de cambios.\n")
        readme_file.write("\n## Proceso de Comunicación\n")
        readme_file.write("La comunicación dentro del equipo se gestionará a través de reuniones semanales y herramientas como [Slack, Microsoft Teams, etc.].\n")

    print(f"Estructura del proyecto '{project_name}' creada exitosamente! ")

# Pide al usuario el nombre del proyecto
project_name = input("Ingresa el nombre del proyecto: ")

# Crea la estructura del proyecto
create_project_structure(project_name)
