import Foundation
import CoreData
import UIKit

class SettingsViewModel {
    
    // MARK: - Properties
    private let settingsSections: [SettingsSection] = [
        SettingsSection(
            title: "앱 정보",
            items: [
                SettingsItem(title: "버전 정보", icon: "info.circle", action: .showVersionInfo),
                SettingsItem(title: "개발자 정보", icon: "person.circle", action: .showDeveloperInfo)
            ]
        ),
        SettingsSection(
            title: "데이터 관리",
            items: [
                SettingsItem(title: "데이터 초기화", icon: "trash.circle", action: .resetData, isDestructive: true)
            ]
        ),
        SettingsSection(
            title: "피드백",
            items: [
                SettingsItem(title: "앱 평가하기", icon: "star.circle", action: .rateApp),
                SettingsItem(title: "버그 신고", icon: "exclamationmark.triangle", action: .reportBug)
            ]
        )
    ]
    
    // MARK: - Public Methods
    func getSettingsSections() -> [SettingsSection] {
        return settingsSections
    }
    
    func getVersionInfo() -> (version: String, build: String, message: String) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let message = "Version: \(version) (Build: \(build))\n\n할 일 관리를 더욱 쉽고 편리하게!"
        
        return (version: version, build: build, message: message)
    }
    
    func getDeveloperInfo() -> String {
        return "개발자: 김기현\n\n더 나은 앱을 만들기 위해 노력하고 있습니다.\n피드백을 언제든 환영합니다!"
    }
    
    func getResetDataMessage() -> String {
        return "모든 카테고리와 할 일이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말로 초기화하시겠습니까?"
    }
    
    func getRateAppMessage() -> String {
        return "App Store에서 평가하기 기능은 실제 앱스토어 출시 후 구현됩니다.\n\n지금은 개발 단계입니다!"
    }
    
    func getBugReportMessage() -> String {
        return "버그나 개선사항이 있으시면 개발자에게 알려주세요.\n\n현재는 개발 단계로 직접 연락을 통해 피드백을 받고 있습니다."
    }
    
    func resetAllData(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(SettingsError.coreDataError("AppDelegate를 찾을 수 없습니다.")))
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        
        let todoFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        let todoDeleteRequest = NSBatchDeleteRequest(fetchRequest: todoFetchRequest)
        todoDeleteRequest.resultType = .resultTypeObjectIDs
        
        let categoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoCategory")
        let categoryDeleteRequest = NSBatchDeleteRequest(fetchRequest: categoryFetchRequest)
        categoryDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            // BatchDelete 실행
            let todoDeleteResult = try persistentStoreCoordinator.execute(todoDeleteRequest, with: managedContext) as? NSBatchDeleteResult
            let categoryDeleteResult = try persistentStoreCoordinator.execute(categoryDeleteRequest, with: managedContext) as? NSBatchDeleteResult
            
            // ObjectIDs를 가져와서 컨텍스트에 변경사항 알림
            var objectIDsToMerge: [NSManagedObjectID] = []
            
            if let todoObjectIDs = todoDeleteResult?.result as? [NSManagedObjectID] {
                objectIDsToMerge.append(contentsOf: todoObjectIDs)
            }
            
            if let categoryObjectIDs = categoryDeleteResult?.result as? [NSManagedObjectID] {
                objectIDsToMerge.append(contentsOf: categoryObjectIDs)
            }
            
            // 변경사항을 컨텍스트에 병합
            let changes = [NSDeletedObjectsKey: objectIDsToMerge]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedContext])
            
            // 컨텍스트 저장
            try managedContext.save()
            
            completion(.success(()))
        } catch {
            completion(.failure(SettingsError.coreDataError("데이터 초기화 중 오류가 발생했습니다: \(error.localizedDescription)")))
        }
    }
}

// MARK: - Error Types
enum SettingsError: LocalizedError {
    case coreDataError(String)
    
    var errorDescription: String? {
        switch self {
        case .coreDataError(let message):
            return message
        }
    }
}

// MARK: - Data Models
struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let title: String
    let icon: String
    let action: SettingsAction
    let isDestructive: Bool
    
    init(title: String, icon: String, action: SettingsAction, isDestructive: Bool = false) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isDestructive = isDestructive
    }
}

enum SettingsAction {
    case showVersionInfo
    case showDeveloperInfo
    case resetData
    case rateApp
    case reportBug
}