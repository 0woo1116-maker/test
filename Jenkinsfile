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
                    
                    // 2. Kind 관리자 권한이 포함된 kubeconfig를 생성하고 내부 IP로 서버 주소 변경
                    sh '''
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        KIND_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
                        echo "Kind Control Plane IP: $KIND_IP"
                        
                        mkdir -p /var/jenkins_home/.kube
                        
                        # Kind 관리자용(kubernetes-admin) 순정 kubeconfig 추출 및 저장
                        kind get kubeconfig --name kind > /var/jenkins_home/.kube/config
                        
                        # 서버 주소만 도커 내부 IP로 안전하게 교체
                        kubectl config set clusters.kind-kind.server https://${KIND_IP}:6443
                        
                        echo "===== Final Config Validation ====="
                        kubectl config current-context
                        kubectl cluster-info
                    '''
                    
                    // 3. 쿠버네티스 배포 적용 및 재시작
                    sh '''
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        kubectl apply -f deployment.yaml --validate=false
                        kubectl rollout restart deployment/reporting-server-app
                    '''
                }
            }
        }
    }
}