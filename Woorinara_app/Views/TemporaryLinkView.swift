import SwiftUI
import VComponents
import VCore

struct TemporaryLinkView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 0) {
                    AppBar(title: "", isMainPage: true)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        List {
                            NavigationLink("여권 / 외국인 등록증 프로세스", destination: ScanView())
                            NavigationLink("통합 신청서 뷰", destination: AFAutoView())
                            NavigationLink("위치 권한 허용", destination: permissionMapView())
                            NavigationLink("My Page", destination: MyPageView())
                            NavigationLink("최초 로그인", destination: ARCInfoView())
                           //                           NavigationLink("로그아웃", destination: LogOutView())
 //                           NavigationLink("회원 탈퇴", destination: DeleteMemberView())
//                            passportInfoLink()
//                            afCenterViewLink()
 //                           NavigationLink("auto", destination: TranslateView())
                        }
                        .navigationTitle("My Page")
                    }
                    Spacer()
                }
                .padding(.bottom, 5)
                .padding(16)
            }
        }
    }



}
