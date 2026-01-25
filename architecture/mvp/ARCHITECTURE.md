아키텍처 설명 문서 (에이전트용)

프로젝트: 토이 프로젝트 - 아이돌 굿즈 중고 장터 (Cherry)

목적

- 이 문서는 현재 운영/배포 환경의 “사실”을 정리한 문서다.
- AI 에이전트는 구현/수정 시 이 문서를 전제로 한다.
- 문서에 없는 인프라 요소(예: EKS, Terraform 등)는 존재하지 않는 것으로 간주한다.

도메인

- Front: https://cheryi.com
- API: https://api.cheryi.com

머메이드 다이어그램

```mermaid
flowchart LR
  U[User Browser] -->|HTTPS 443| CF[CloudFront - Front CDN]
  CF -->|GET static assets| S3[S3 - Static Website Bucket]

  U -->|HTTPS 443 / API calls| ALB[Application Load Balancer - api.cheryi.com]
  ALB -->|Forward HTTP 8080| EC2[EC2 Instance (Docker Compose)]
  EC2 -->|JDBC 3306| RDS[(RDS MySQL)]
  EC2 -->|TCP 6379| Redis[(Redis Container)]

  subgraph VPC[AWS VPC (ap-northeast-2)]
    ALB
    EC2
    RDS
  end
```

트래픽 흐름 (런타임)

1. 사용자가 브라우저에서 https://cheryi.com 접속

- CloudFront가 S3에 업로드된 정적 파일(React/Vite 빌드 결과)을 서빙한다.
- 브라우저는 동일 도메인에서 JS/CSS/이미지를 로드한다.

2. 프론트엔드가 API 호출

- 브라우저에서 https://api.cheryi.com 으로 API 요청을 보낸다.
  - 요청은 ALB(HTTPS 443)로 들어간다.
  - ALB는 Target Group을 통해 EC2의 애플리케이션 포트(HTTP 8080)로 포워딩한다.
- Spring Boot는 비즈니스 로직 처리 중 RDS(MySQL)와 Redis를 사용한다.
- 응답은 ALB를 통해 브라우저로 반환된다.

포트/프로토콜

- Front 도메인 (cheryi.com)
  - 사용자 → CloudFront: HTTPS 443
  - CloudFront → S3: AWS 내부 통신(정적 파일 GET)
- API 도메인 (api.cheryi.com)
  - 사용자 → ALB: HTTPS 443
  - ALB → EC2 app 컨테이너: HTTP 8080
  - EC2 app → RDS MySQL: TCP 3306
  - app 컨테이너 → redis 컨테이너: TCP 6379 (docker network)

보안 경계/인증서

- 인증서(ACM)는 api.cheryi.com에 대해 발급되어 ALB(HTTPS Listener)에 연결된다.
- 프론트(cheryi.com)는 CloudFront/도메인 쪽에서 HTTPS 제공(별도 인증서 관리).
- API는 프론트 도메인과 다른 Origin이므로, prod에서는 CORS를 https://cheryi.com만 허용한다.

배포 흐름
Front 배포 - GitHub Actions로 프론트 빌드 - 빌드 결과물을 S3에 업로드 - CloudFront가 S3의 정적 파일을 캐시/서빙

Backend 배포 - GitHub Actions로 백엔드 Docker 이미지 빌드 → GHCR push - EC2에서 docker compose로 이미지 pull 후 컨테이너 재시작 - 환경변수는 GitHub Secrets에서 전달되어 EC2에 .env 생성 후 docker compose –env-file로 주입 - 컨테이너는 8080 포트로 구동

운영 환경의 “사실” 체크리스트 - EC2 내부: curl http://localhost:8080/health 는 200이어야 한다. - 외부: curl https://api.cheryi.com/health 는 200이어야 한다. - 브라우저에서 https://cheryi.com은 정적 화면을 정상 렌더링해야 한다. - 브라우저에서 API 호출 시 CORS 정책은 prod에서 https://cheryi.com만 허용해야 한다.

에이전트 작업 규칙 - 인프라 변경(ALB/CloudFront/S3/Route53/ACM)은 별도 지시 없으면 하지 않는다. - 백엔드 관련 수정은 기본적으로 “EC2 Docker Compose + ALB 443→8080”을 전제로 한다. - 프론트 관련 수정은 기본적으로 “S3 + CloudFront 정적 배포”를 전제로 한다. - API Base URL(prod)은 https://api.cheryi.com 이다. - Front URL(prod)은 https://cheryi.com 이다.
