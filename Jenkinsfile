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
                    
                    // 2. kubeconfig 파일을 루프백(127.0.0.1) 없이 내부망 주소로 완전히 새로 작성
                    sh '''
                        mkdir -p /var/jenkins_home/.kube
                        cat <<EOF > /var/jenkins_home/.kube/config
apiVersion: v1
clusters:
- cluster:
    server: https://kind-control-plane:6443
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
    client-certificate-data: $(kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}')
    client-key-data: $(kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}')
EOF
                    '''
                    
                    // 3. 쿠버네티스 배포 적용 및 재시작
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}