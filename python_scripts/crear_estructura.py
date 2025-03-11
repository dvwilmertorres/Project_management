import os
import subprocess
import sys
import openpyxl
from openpyxl.styles import Alignment

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
        "1.product_vision","2.release_planning", "3.roadmap","4.user_stories","5.product_backlog",
        "6.sprint_planning","7.sprint_backlog","8.definition_of_done","9.product_design","10.testing",
         "11.documentation", "12.release_deployment", "13.maintenance_monitoring"      
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

    # Crear el archivo Excel en la carpeta de recursos
    excel_path = f"{project_name}/5.resources/Resources.xlsx"
    wb = openpyxl.Workbook()

    # Crear la hoja "Resources"
    ws_resources = wb.active
    ws_resources.title = "Resources"
    ws_resources['A1'] = "Resource Name"
    ws_resources['B1'] = "Resource Type"
    ws_resources['C1'] = "Description"
    ws_resources['D1'] = "Quantity"
    
    # Agregar algunas celdas iniciales para el archivo Excel
    ws_resources['A1'].alignment = Alignment(horizontal='center', vertical='center')
    ws_resources['B1'].alignment = Alignment(horizontal='center', vertical='center')
    ws_resources['C1'].alignment = Alignment(horizontal='center', vertical='center')
    ws_resources['D1'].alignment = Alignment(horizontal='center', vertical='center')

    # Crear la hoja de "Seguimiento del Proyecto"
    ws_tracking = wb.create_sheet(title="Project Tracking")
    
    # Definir los encabezados de las columnas
    headers = ["Task ID", "Task Name", "Assigned To", "Start Date", "Due Date", "Status", "Comments"]
    ws_tracking.append(headers)

    # Ajustar el alineamiento de los encabezados
    for cell in ws_tracking[1]:
        cell.alignment = Alignment(horizontal='center', vertical='center')

    # Ejemplo de reporte de seguimiento del proyecto (esto es un ejemplo, puedes modificarlo)
    tasks = [
        [1, "Definir visión del producto", "Juan Pérez", "2025-03-01", "2025-03-05", "Completed", "Visión aprobada por los stakeholders."],
        [2, "Planificación de la primera versión", "Ana Gómez", "2025-03-06", "2025-03-10", "In Progress", "Se están finalizando los requisitos."],
        [3, "Desarrollo de la funcionalidad principal", "Carlos Rodríguez", "2025-03-11", "2025-03-20", "Pending", "Pendiente de revisión inicial."],
    ]

    # Agregar las tareas al reporte de seguimiento
    for task in tasks:
        ws_tracking.append(task)

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
        for subdir in doc_subdirectories:
            readme_file.write(f"│   ├── {subdir}/\n")
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

    print(f"Estructura del proyecto '{project_name}' creada exitosamente con el reporte de seguimiento! ")

# Pide al usuario el nombre del proyecto
project_name = input("Ingresa el nombre del proyecto: ")

# Crea la estructura del proyecto
create_project_structure(project_name)
