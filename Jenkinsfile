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
                    
                    // 2. KUBECONFIG 경로를 명시적으로 고정하고 인증서와 컨텍스트가 포함된 config 파일 생성
                    sh '''
                        # 0순위로 kubectl이 참조할 설정 파일 경로를 절대 경로로 고정
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        
                        KIND_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
                        echo "Kind Control Plane IP: $KIND_IP"
                        
                        mkdir -p /var/jenkins_home/.kube
                        
                        # 킨드 컨트롤 플레인 내부에서 인증서 추출
                        CA_DATA=$(docker exec kind-control-plane cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '\\n')
                        CLIENT_CERT_DATA=$(docker exec kind-control-plane cat /etc/kubernetes/pki/apiserver-kubelet-client.crt | base64 | tr -d '\\n')
                        CLIENT_KEY_DATA=$(docker exec kind-control-plane cat /etc/kubernetes/pki/apiserver-kubelet-client.key | base64 | tr -d '\\n')
                        
                        # KUBECONFIG 파일 직접 작성
                        cat <<EOF > /var/jenkins_home/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA_DATA}
    server: https://${KIND_IP}:6443
  name: kind-kind
contexts:
- context:
    cluster: kind-kind
    user: kind-kind
  name: kind-kind
current-context: kind-kind
kind: Config
preferences: {}
users:
- name: kind-kind
  user:
    client-certificate-data: ${CLIENT_CERT_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
EOF

                        echo "===== Final Config Validation ====="
                        kubectl config current-context
                        kubectl cluster-info
                    '''
                    
                    // 3. 쿠버네티스 배포 적용 및 재시작 (동일하게 KUBECONFIG 환경변수 유지)
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