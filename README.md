# Github Link

https://github.com/CLD-3rd/team2-frontend

https://github.com/CLD-3rd/team2-backend

https://github.com/CLD-3rd/team2-infra

---
<br><br><br>
# Save My Podo

### 🍇 안정적이고 확장 가능한 공연 예매 시스템

### **프로젝트 개요**

공연 예매 시 발생할 수 있는 동시 접속, 좌석 중복 선택 문제를 해결하고, 안정적인 사용자 경험을 제공하기 위해 개발된 공연 예매 시스템입니다. 공연 목록 조회, 좌석 선택 및 예매, 예매 현황 확인 등 예매에 꼭 필요한 핵심 기능만을 구현하여 효율성과 안정성을 높였습니다.

### **핵심 기술 및 특징**

- **동시성 제어**: 다수의 사용자가 동시에 같은 좌석을 선택해도 중복 예매가 발생하지 않도록 락 및 트랜잭션 처리 설계
- **인프라 스케일링**: 사용자 급증 시 자동으로 리소스를 확장할 수 있는 클라우드 기반 구조 구현
- **안정적인 운영환경**: 장애 대응을 위한 무중단 배포 전략 및 헬스체크 설정
- **인프라 모니터링**: 예매 트래픽, 서버 상태, 에러 로그 등을 실시간 모니터링하여 안정적인 서비스 유지

### **주요 기능**

- 공연 목록 조회
- 좌석 선택 및 예매
- 예매 현황 확인

# 🛠 사용한 기술

- 프론트엔드: React, Tailwind, Vite
- 백엔드: SpringBoot, Redis, MySQL
- AWS 인프라: S3, RDS, ElastiCache, Cloudfront, SSM Parameter, EKS, Client VPN, Cloudwatch, SNS, Route53
- EKS 모니터링: Prometheus, Grafana, K6, fluentbit
- CI/CD: Github Actions, ArgoCD, Kustomize
  
<br><br><br>

# 🖥 페이지별 기능 소개

## 메인 페이지

로그인 하지 않은 경우
<img width="978" height="993" alt="Image" src="https://github.com/user-attachments/assets/d6118ffd-a219-489d-b1d8-8c593f61510e" />


로그인 한 경우
<img width="981" height="996" alt="Image" src="https://github.com/user-attachments/assets/7e0f9f1b-3463-4b10-b721-a0de11928443" />



❌ 비로그인시:

- 예매 버튼 비노출 **예매 불가**
- 우측 상단에 **Login 버튼만 표시됨**

⭕ 로그인시:

- 우측 상단에 사용자명 + Logout 표시
- 각 공연 카드에 **예매 상태에 따른 버튼 노출**

| **예매 상태** | **버튼 노출** |
| --- | --- |
| 예매 가능한 공연 | **[예매하기] 버튼 활성화** |
| 이미 예매한 공연 | **[취소하기] 버튼으로 표시 변경** |
| 매진된 공연 | **버튼 비활성화** |


---


## 로그인 페이지

<img width="869" height="465" alt="Image" src="https://github.com/user-attachments/assets/5c128543-19fb-4314-9423-0425b3e7806f" />

- 상단의 **[Login] 버튼 클릭 시**, Google OAuth 인증 창이 새 창으로 열립니다.
- 사용자는 **Google 계정 정보를 입력하여 로그인**할 수 있으며, 로그인 후 사용자 정보가 백엔드에 전달되어 인증/인가가 처리됩니다.
- 로그인에 성공하면 메인 페이지로 리디렉션되며, 사용자 이름과 함께 **[Logout] 버튼**이 우측 상단에 표시됩니다.


---


## 예매 페이지

<img width="1332" height="994" alt="Image" src="https://github.com/user-attachments/assets/1361509b-b5c0-440e-bf8a-81b393d903f6" />

<img width="1327" height="996" alt="Image" src="https://github.com/user-attachments/assets/afb40216-efde-41e4-a489-5f72762d26d3" />

<img width="1327" height="995" alt="Image" src="https://github.com/user-attachments/assets/2207f17b-f0ae-4a7b-8c84-4898dc292686" />

<img width="1325" height="990" alt="Image" src="https://github.com/user-attachments/assets/4743b109-e74c-4678-8db4-64385f04ea56" />

- **좌석 상세 설명**
    - 🟩 **초록색 (Available)**: 예매가 가능한 좌석입니다.
    - 🟪 **보라색 (Selected)**: 사용자가 현재 선택한 좌석입니다.
    - ❌ **회색 (Reserved)**: 다른 사용자가 이미 예매한 좌석으로 선택이 불가능합니다.
- **예매 절차 설명**
    1. 사용자가 좌석을 클릭하여 선택하면, 오른쪽 예매 정보 창에 **좌석 번호 및 가격**이 표시됩니다.
    2. [Reserve] 버튼을 클릭하면 **예매 확정 확인 팝업**이 표시됩니다.
        - 공연명, 일시, 좌석, 총 금액을 확인 후 [Yes] 클릭 시 예매가 진행됩니다.
    3. 예매가 완료되면 **“예약 완료” 팝업**이 뜨고, 해당 좌석은 즉시 회색으로 바뀌어 **다른 사용자가 예약할 수 없게 됩니다.**
- **예매 완료 후**
    - 상단 탭의 [**My Reservations**] 메뉴에서 사용자가 예매한 공연을 확인할 수 있습니다.
    - 메인 페이지에서도 예매한 공연은 **[Cancel Reservation] 버튼**이 활성화되어, 사용자는 예약을 취소할 수 있습니다.



<br><br><br>
# ⚙ 인프라 구성도

<img width="2653" height="2159" alt="Image" src="https://github.com/user-attachments/assets/11258fa8-c33e-4c0b-be48-be3c44c8f9be" />

- **프론트엔드**
    - S3 Website Hosting 에 cloudfront 연결 후 도메인 설정
    - S3 코드 업로드 및 Cloudfront 캐싱 무효화하여 최신 코드 반영하는 CI/CD 작성
        - Github Actions용 OIDC를 발급해 최소권한으로 AWS 리소스 제어
- **백엔드**
    - EKS 클러스터 내부에 ArgoCD를 사용해 자동 배포
    - 롤링 업데이트 및 HPA AutoScaling, AutoScaling Group을 적용하여 무중단 배포 및 인프라 스케일링
    - 데이터베이스로 RDS(MySQL), ElastiCache(Redis) 사용
        - RDS에 CloudWatch Metric과 SNS를 연동하여 5개의 임계값을 지정, 초과 시 현재 상태와 대처 매뉴얼을 포함한 메일 전송
- **네트워크**
    - VPC 1개에 Private Subnet 3개, Public Subnet 3개 배치
    - Private Subnet에 RDS, ElastiCache, EKS 클러스터 배치
    - Public Subnet에 IGW, NAT_GW 배치하여 Private Subnet 리소스의 인터넷 통신 허용
- **보안**
    - 개발자 편의를 위해 Client VPN Endpoint를 생성하여 VPC Private Subnet 내부 리소스에 접근할 수 있도록 허용
    - 모든 모니터링 리소스의 로드밸런서는 internal로 설정하여 팀원만 접속 가능
    - 배포 스크립트 Github 업로드 시 민감정보 보호를 위해 SSM Parameter에 패스워드 정보 저장 및 호출
    - EKS 클러스터 내부의 AWS 리소스를 사용하는 Pod용 IRSA 설정
- **모니터링**
    - Prometheus로 EKS 클러스터 및 백엔드 서버 메트릭 수집
    - FluentBit으로 pod 로그 수집하여 CloudWatch로 전송
    - Grafana에서 대시보드로 메트릭 시각화 및 로그 확인
 

<br><br><br>
# 🔎 Redis 캐싱 전략

### **📌 목적**

- **빠른 응답성** 확보 및 **DB 부하 감소**
- **토큰, 인기 공연, 좌석 정보 등** 자주 조회되는 데이터를 인메모리 캐시로 관리

### **🧩 사용 영역**

| **용도** | **설명** | **Key 예시** | **TTL** |
| --- | --- | --- | --- |
| 🔐 Refresh Token | 사용자 인증용 토큰 저장 | refreshtoken:{userId} | 7일 |
| 🎫 인기/최신 공연 | 메인 페이지 Top 5 공연 캐싱 | popular:musicals:hot
popular:musicals:new | 10분 |
| 🎟 공연 좌석 정보 | 공연별 좌석 목록 캐싱 | seats:hot:{musicalId} | 10분 |


<br><br><br>
# 📈 모니터링 및 테스트

## **1. 시스템 모니터링**

### **1-1. 실시간 클러스터 모니터링**

- **kube-ops-view**
    
    → 노드 및 파드의 배치 상태를 실시간으로 시각화
    

<img width="749" height="265" alt="Image" src="https://github.com/user-attachments/assets/78a02c67-8c74-49e3-8894-f12a0062b8c5" />

---

### **1-2. 성능 및 자원 사용 모니터링**

- **Prometheus**
    
    → 메트릭 수집 및 쿼리 수행
    

<img width="1894" height="725" alt="Image" src="https://github.com/user-attachments/assets/d0ee073e-1432-4f3f-9d82-9555ac00e96f" />

---

- **Grafana**
    
    → 총 33개 대시보드를 활용해 전체 리소스 및 애플리케이션 상태 모니터링
    
    → 대시보드 목록
    

<img width="1193" height="843" alt="Image" src="https://github.com/user-attachments/assets/783e8709-548e-4141-847c-f4b42a87645d" />

---

- **JVM (SpringBoot) 대시보드 (로그 패널 추가)**

<img width="1638" height="908" alt="Image" src="https://github.com/user-attachments/assets/b5e97851-3fb3-4f3a-bc05-cd816a97da80" />

---

- **EKS 클러스터 / 네트워크**

<img width="1564" height="897" alt="Image" src="https://github.com/user-attachments/assets/cfea8acb-bc57-494b-9424-96b897339b00" />

<img width="1581" height="903" alt="Image" src="https://github.com/user-attachments/assets/155eddb8-fa24-4f02-b1e6-6bc33cf64c38" />

---

- **RDS / ElastiCache**

<img width="1574" height="899" alt="Image" src="https://github.com/user-attachments/assets/983975cc-8d4a-4adf-ba3b-3042bc8ef132" />

<img width="1567" height="898" alt="Image" src="https://github.com/user-attachments/assets/ab95e553-2c23-4f6e-9215-e2b68761a0fd" />

---

### **1-3. 알람 및 경고 시스템**

- **CloudWatch + SNS**
    
    → RDS CPU 임계치 초과 시 알람 발생
    

<img width="1580" height="723" alt="Image" src="https://github.com/user-attachments/assets/cfba66d7-41b9-4cc1-a72e-736cc6b0928d" />

<br><br><br>

## **2. 성능 테스트 (K6)**

### **2-1. 테스트 목적**

- **DB 조회** vs **Redis 캐시 조회** 성능 비교
- 시스템 과부하 환경에서의 응답 속도 및 에러율 측정

---

### **2-2. 테스트 시나리오**

- 점진적 VU 증가 (최대 600명 동시 사용자)
- 90% 응답 3초 이하, 에러율 20% 이하 목표

```jsx
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {

    stages: [
        { duration: '30s', target: 50 },  // 30초 동안 0 -> 50 VUs
        { duration: '50s', target: 150 }, // 다음 50초 동안 50 -> 150 VUs (t3.medium에 부담 주기 시작)
        { duration: '50s', target: 300 }, // 다음 50초 동안 150 -> 300 VUs (CPU 크레딧 소모 가속, 메모리 압박)
        { duration: '20s', target: 600 }, // 다음 20초 동안 300 -> 600 VUs (최대 스케일아웃/CPU 스로틀링 유도)
        { duration: '30s', target: 600 }, // 다음 30초 동안 600 VUs 유지
        { duration: '20s', target: 0 },   // 마지막 20초 동안 600 -> 0 VUs
    ],

    thresholds: {
        'http_req_duration': [
        // 90% 응답 시간이 3초 이내 (느슨하게, 평소보다 훨씬 길어질 것 예상)
        'p(90)<3000',
        // 95% 응답 시간이 5초 이내 (더욱 느슨하게, 장애 지점을 확인하기 위함)
        'p(95)<5000',
        ],
        'http_req_failed': [    
        'rate<0.2' // 에러율이 20% 미만 (평소보다 높은 에러율을 허용하여 시스템의 한계를 확인)
        ]
    }
};

export default function () {

    let res = http.get('http://127.0.0.1:8080/api/test/performance/musicals/all');

    check(res, {
        'status is 200': (r) => r.status === 200, // HTTP 응답코드가 200인지 검사
        'response time < 1000ms': (r) => r.timings.duration < 1000 // 응답 시간이 1000ms 미만인지 검사
    });
    // 밑에 줄은 좌석 정보 조회할 때만 추가
		sleep(0.1); // 예매 서비스의 특성 상, Refresh 요청이 많을 것으로 예상되어 각 요청 사이에 0.1초 대기
}

export function setup() {
    console.log('테스트 시작: /api/musicals 과부하 시나리오');
    return {};
}

export function teardown(data) {
    console.log('테스트 종료: 과부하 시나리오 결과 확인');
}
```

- 테스트 대상 API

| **테스트 항목** | **URL** |
| --- | --- |
| 공연 전체 조회 (DB) | /api/test/performance/musicals/all |
| 공연 인기 조회 (캐시) | /api/test/performance/musicals/top5 |
| 좌석 조회 (DB) | /api/test/performance/seats/{musicalId}/db |
| 좌석 조회 (캐시) | /api/test/performance/seats/{musicalId}/cached |
- 테스트에 사용된 데이터

| 테이블 | 데이터 수 |
| --- | --- |
| musicals | 200 |
| seats | 140 |

---

### **2-3. 테스트 결과**

**🎭 공연 조회**

1. DB 조회

<img width="875" height="347" alt="Image" src="https://github.com/user-attachments/assets/9d8b8336-11f5-41b3-86cf-c85efd279114" />

1. 캐시 조회

<img width="858" height="341" alt="Image" src="https://github.com/user-attachments/assets/89278c67-5756-4a03-86ef-bf0c34b59556" />

---

**🎫 좌석 조회**

1. DB 조회

<img width="908" height="340" alt="Image" src="https://github.com/user-attachments/assets/d589a270-ce5e-45b8-8a64-3a51822c851a" />

1. 캐시 조회

<img width="887" height="344" alt="Image" src="https://github.com/user-attachments/assets/1ee787df-6930-4fe8-a990-7638ed54b2db" />

<br><br><br>

## **3. 동시성 테스트**

### **3-1. 목적**

- **동일 좌석**에 대한 **동시 예약 요청** 처리 검증
- Redisson 기반의 분산 락 적용

---

### **3-2. 주요 구현 포인트**

| **단계** | **내용** |
| --- | --- |
| 🔑 락 키 | `lock:seat:{musicalId}:{seatName}` |
| 🛠 락 획득 | `tryLock(5, 10, TimeUnit.SECONDS)` |
| 🧾 예약 처리 | `doReservation()` 트랜잭션 내부 처리 |
| 🧹 정리 | `finally { lock.unlock(); }` |

<aside>
🔐

**락 획득 조건**

- 최대 5초까지 대기
- **최대 10초까지 점유**
- 락 획득 실패 시 예외 발생: `SEAT_LOCK_FAILED`
</aside>

### **3-3. 테스트 결과**

**🧪 로컬 테스트: @SpringBootTest 기반**

- 서로 다른 사용자 2명이 **동일 좌석 A1**에 **동시에 예약 요청**
- 스레드 2개로 ExecutorService, CountDownLatch 사용
- 기대 결과: **1명만 성공**, 나머지는 **“이미 예약됨”** 예외 발생

```jsx
@SpringBootTest
@DisplayName("동시 좌석 예약 테스트")
@Rollback
class ReservationLockTest {

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MusicalRepository musicalRepository;

    private User user1;
    private User user2;
    private Musical musical;

    @BeforeEach
    void setUp() {
        user1 = userRepository.findByEmail("user1@test.com")
                .orElseGet(() -> userRepository.save(User.builder()
                        .email("user1@test.com")
                        .nickname("user1")
                        .provider(Provider.GOOGLE)
                        .providerId("u1")
                        .role(Role.USER)
                        .build()));

        user2 = userRepository.findByEmail("user2@test.com")
                .orElseGet(() -> userRepository.save(User.builder()
                        .email("user2@test.com")
                        .nickname("user2")
                        .provider(Provider.GOOGLE)
                        .providerId("u2")
                        .role(Role.USER)
                        .build()));

        musical = musicalRepository.save(Musical.builder()
                .title("동시성 테스트 뮤지컬")
                .posterUrl("https://example.com/poster.jpg")
                .startTime(LocalTime.of(19, 0))
                .endTime(LocalTime.of(21, 0))
                .description("락 테스트용 공연")
                .date(LocalDate.now().plusDays(1))
                .price(10000L)
                .location("테스트 공연장")
                .reservedCount(0L)
                .build());
    }

    @Test
    @DisplayName("동일 좌석을 동시에 예약하면 하나만 성공해야 함")
    void testConcurrentReservation() throws InterruptedException {
        int threadCount = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);

        List<Exception> exceptions = Collections.synchronizedList(new ArrayList<>());

        String seatName = "A1";
        Long mid = musical.getId(); // 🎯 한 번만 안전하게 저장해서 공유

        executor.submit(() -> {
            try {
                reservationService.createReservationWithLock(user1, mid, seatName);
            } catch (Exception e) {
                exceptions.add(e);
            } finally {
                latch.countDown();
            }
        });

        executor.submit(() -> {
            try {
                reservationService.createReservationWithLock(user2, mid, seatName);
            } catch (Exception e) {
                exceptions.add(e);
            } finally {
                latch.countDown();
            }
        });

        latch.await();

        // 예외가 정확히 1개 발생해야 동시성 제어 성공
        Assertions.assertEquals(1, exceptions.size(), "동시에 예약하면 하나는 실패해야 한다.");

        System.out.println("❗예외 메시지: " + exceptions.get(0).getMessage());
    }

}

```

| **사용자** | **락 획득 여부** | **결과** |
| --- | --- | --- |
| user1 | 성공 | 예약 성공 (200 OK) |
| user2 | 실패 | 중복 예외 발생 (400 Bad Request) |

**🔍 로그로 확인된 점**

<img width="2264" height="100" alt="Image" src="https://github.com/user-attachments/assets/0a0b14f9-1882-44f6-816e-b8abbd390e8d" />

- **락 키가 동일**하게 생성됨 (`lock:seat:1:A1`)
- **둘 다 락을 얻었지만**, 순차적으로 실행됨
- 두 번째는 좌석이 이미 insert되어 있어서 예외 발생

---

**🧪 배포 환경 테스트: k6 부하 테스트**

- JWT 토큰을 가진 사용자 2명이 동시에 동일 좌석에 POST 요청

```bash
POST https://api.savemypodo.shop/api/reservations/1
Body: { "seatName": "A1" }
```

```jsx
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 2,         // 가상 사용자 2명
  iterations: 2, // 총 2번 요청 (각 사용자당 1회)
};

// 실제 사용자 토큰을 여기 넣어줘
const TOKENS = [
  'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtaWNoZWxsZTIwMDMyM0BnbWFpbC5jb20iLCJyb2xlIjoiUk9MRV9VU0VSIiwiaWF0IjoxNzUyNTc1MjI4LCJleHAiOjE3NTI1NzcwMjh9.vlS7sZiYSgmpv3jix03x7fctZT5xM22jFzTmnfPATfQ',
  'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjanNxdWR3bnMyNzgxQGdtYWlsLmNvbSIsInJvbGUiOiJST0xFX1VTRVIiLCJpYXQiOjE3NTI1NzUxMzksImV4cCI6MTc1MjU3NjkzOX0.M5VlNMemdm3cgvFBJ8stGV5Phy00bH8yw6h4BgDuMgQ',
];

export default function () {
  const userIndex = __VU - 1; // __VU는 1부터 시작하므로 배열 인덱스는 -1
  const token = TOKENS[userIndex];

  const url = 'https://api.savemypodo.shop/api/reservations/1';
  const payload = JSON.stringify({
    seatName: 'A1',
  });

  const headers = {
    'Content-Type': 'application/json',
    'Authorization': token,
  };

  const res = http.post(url, payload, { headers });

  check(res, {
    'status is 200 or 400': (r) => r.status === 200 || r.status === 400,
  });

  console.log(`VU: ${__VU}, status: ${res.status}, body: ${res.body}`);
}
```

```jsx
export const options = { vus: 2, iterations: 2 };
```

- 각각의 JWT 토큰을 이용해 인증
- 요청 URL: `POST https://api.savemypodo.shop/api/reservations/1`
- 응답 status 200 또는 400만 허용 (`check()`로 필터링)

<img width="1357" height="427" alt="Image" src="https://github.com/user-attachments/assets/6ed839cf-5537-43ec-bfab-1653755d106f" />

**📋 결과 로그 예시**

```bash
VU: 1, status: 200, body: {"message":"성공적으로 예약이 되었습니다."}
VU: 2, status: 400, body: {"message":"이미 예약된 좌석입니다."}
```

**📈 성능 요약**

| **항목** | **값** |
| --- | --- |
| 총 요청 | 2 |
| 성공 | 1 (200 OK) |
| 실패 | 1 (400 Bad Request) |
| 평균 응답 시간 | 약 275ms |
| 실패율 | 0% (예상된 실패만 존재)**결론** |

**✅ 결론**

- 🎯 **Redisson 분산 락** 방어 성공
- ✅ 로컬과 실서버 환경 모두에서 **동시성 문제 없음** 확인
- 🚀 실서비스에서도 좌석 중복 예약 문제 없이 운영 가능

<br><br><br>

# 👩🏻‍💻 역할 분배

| 이름 | 역할 | 세부 역할 |
| --- | --- | --- |
| 박시윤 | 팀장, 인프라 | 테라폼 AWS 인프라, EKS 클러스터 구축 및 모니터링 설정 |
| 문지현 | 부팀장, 프론트엔드 | 프론트엔드 구현 및 CI/CD 작성, k6 시나리오 작성, 산출물 취합 |
| 한재선 | 프론트엔드 | 프론트엔드 개발 화면 구현, 문서화 작업 |
| 박장호 | 백엔드 | 벡엔드 메인 페이지 기능 구현, k6 테스트 진행 |
| 서예은 | 백엔드 | 백엔드 기능 구현, 동시성 제어(JPA 락)와 관련 테스트 실행 |
| 천병준 | 백엔드 | 백엔드 인증 및 보안 (JWT 기반 인증) |


