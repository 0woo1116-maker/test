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
                    // 1. 디플로이먼트 파일 이미지 태그 교체
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // 2. 인증서와 유저 정보를 날리지 않고, 내부 IP 서버 주소와 컨텍스트만 안전하게 설정
                    sh '''
                        KIND_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
                        echo "Kind Control Plane IP: $KIND_IP"
                        
                        CLUSTER_NAME=$(kubectl config get-clusters | awk 'NR>1 {print; exit}')
                        echo "Target Cluster Name: $CLUSTER_NAME"
                        
                        # 서버 주소를 도커 내부 IP로 변경
                        kubectl config set clusters.$CLUSTER_NAME.server https://$KIND_IP:6443
                        
                        # 현재 컨텍스트를 kind-kind (또는 첫 번째 컨텍스트)로 강제 지정하여 인증 정보 활성화
                        kubectl config use-context kind-kind || kubectl config use-context $(kubectl config get-contexts -o name | head -n 1)
                        
                        echo "===== Final Kubeconfig Validation ====="
                        kubectl config current-context
                    '''
                    
                    // 3. 쿠버네티스 배포 적용 및 재시작
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}