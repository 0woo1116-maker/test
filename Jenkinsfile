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
                    
                    // 2. kind 명령어로 인증서 + 컨텍스트가 모두 포함된 kubeconfig를 완전히 새로 생성하고 내부 IP로 교체
                    sh '''
                        KIND_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
                        echo "Kind Control Plane IP: $KIND_IP"
                        
                        mkdir -p /var/jenkins_home/.kube
                        
                        # kind 자체 명령어로 현재 킨드 클러스터의 온전한 config를 가져와서 덮어쓰기
                        kind get kubeconfig --name kind > /var/jenkins_home/.kube/config
                        
                        # 서버 주소만 도커 내부 IP로 안전하게 교체
                        CLUSTER_NAME=$(kubectl config get-clusters | awk 'NR>1 {print; exit}')
                        kubectl config set clusters.$CLUSTER_NAME.server https://$KIND_IP:6443
                        
                        echo "===== Config Validation Success ====="
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