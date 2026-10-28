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
                    
                    // 2. 젠킨스 전용 kubeconfig 경로를 분리 (/tmp 사용으로 호스트 설정 보호)
                    sh '''
                        export KUBECONFIG=/tmp/jenkins-kind-config
                        KIND_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
                        echo "Kind Control Plane IP: $KIND_IP"
                        
                        # 젠킨스 전용 경로에 킨드 설정 추출
                        kind get kubeconfig --name kind > /tmp/jenkins-kind-config
                        
                        # 젠킨스 전용 파일의 서버 주소만 도커 내부 IP로 교체 (호스트 파일은 안전함!)
                        kubectl config set clusters.kind-kind.server https://${KIND_IP}:6443
                        
                        echo "===== Final Config Validation ====="
                        kubectl config current-context
                        kubectl cluster-info
                    '''
                    
                    // 3. 젠킨스 전용 KUBECONFIG를 사용해 배포 적용
                    sh '''
                        export KUBECONFIG=/tmp/jenkins-kind-config
                        kubectl apply -f deployment.yaml --validate=false
                        kubectl rollout restart deployment/reporting-server-app
                    '''
                }
            }
        }
    }
}