pipeline {
    agent any

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/0woo1116-maker/test.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh "docker build --no-cache -t reporting-server:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Kind Image Load') {
            steps {
                script {
                    sh "docker save reporting-server:${BUILD_NUMBER} -o reporting-server.tar"
                    sh "docker cp reporting-server.tar kind-control-plane:/reporting-server.tar"
                    sh "docker exec kind-control-plane ctr -n k8s.io images import /reporting-server.tar"
                    sh "rm reporting-server.tar"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    // 1. 디플로이먼트 파일의 이미지 태그를 현재 빌드 번호로 교체
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // 2. kind-control-plane의 도커 내부 IP를 직접 조회해서 kubeconfig의 서버 주소로 강제 주입
                    sh '''
                        KIND_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
                        echo "Kind Control Plane IP: $KIND_IP"
                        
                        CLUSTER_NAME=$(kubectl config get-clusters | awk 'NR>1 {print; exit}')
                        kubectl config set clusters.$CLUSTER_NAME.server https://$KIND_IP:6443
                    '''
                    
                    // 3. 쿠버네티스 배포 적용 및 재시작
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}