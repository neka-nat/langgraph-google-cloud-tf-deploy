import os

from diagrams import Diagram, Cluster, Edge
from diagrams.custom import Custom
from diagrams.onprem.client import Users
from diagrams.generic.blank import Blank

from diagrams.gcp.compute import Run

from diagrams.gcp.database import SQL
try:
    from diagrams.gcp.database import Memorystore
except Exception:
    Memorystore = Blank  # fallback

from diagrams.gcp.devtools import Build
try:
    from diagrams.gcp.devtools import ArtifactRegistry as ArtifactNode
except Exception:
    try:
        from diagrams.gcp.devtools import ContainerRegistry as ArtifactNode
    except Exception:
        ArtifactNode = Blank

try:
    from diagrams.gcp.security import SecretManager as SecretNode
except Exception:
    try:
        from diagrams.gcp.security import KMS as SecretNode
    except Exception:
        SecretNode = Blank

TITLE = "LangGraph on Google Cloud"
FILENAME = "gcp_langgraph_arch"


with Diagram(TITLE, filename=FILENAME, outformat="png", show=False, direction="LR"):
    public = Users("Public (allUsers)\nCloud Run Invoker")

    with Cluster(f"GCP Project"):
        # CI/CD + Image Registry
        with Cluster("CI/CD & Container Image"):
            cloud_build = Build("Cloud Build\n(gcloud builds submit)")
            artifact = ArtifactNode(f"Artifact Registry / Container Registry")
            cloud_build >> Edge(label="push image") >> artifact

        # Secrets
        with Cluster("Secrets"):
            sm_db = SecretNode("DATABASE_PASSWORD")
            sm_oai = SecretNode("OPENAI_API_KEY")
            sm_ls = SecretNode("LANGSMITH_API_KEY")

        # Network
        with Cluster(f"VPC Network"):
            vpc_connector = Custom(f"Serverless VPC Access", os.path.join(os.path.dirname(__file__), "serverless-vpc.png"))
            redis = Memorystore(f"Memorystore (Redis)")
            vpc_connector >> Edge(label="Private ranges only") >> redis

        # Data
        with Cluster("Data"):
            sql = SQL(f"Cloud SQL (Postgres 16)")

        # App
        app = Run(f"Cloud Run")

        # External access
        public >> Edge(label="HTTPS") >> app

        # Image to Cloud Run
        artifact >> Edge(label="container_image_url") >> app

        # Secrets → Cloud Run
        sm_oai >> Edge(label="env: OPENAI_API_KEY (latest)") >> app
        sm_ls  >> Edge(label="env: LANGSMITH_API_KEY (latest)") >> app

        # DB password → Cloud SQL（ユーザ作成に利用）
        sm_db >> Edge(style="dashed", label="set postgres password") >> sql

        # Cloud Run ↔ Cloud SQL（/cloudsql マウント）
        app >> Edge(label="/cloudsql mount\nPOSTGRES_URI") >> sql

        # Cloud Run → VPC Connector → Redis
        app >> Edge(label="serverless connector") >> vpc_connector
        app >> Edge(style="dotted", label="REDIS_URI") >> redis
