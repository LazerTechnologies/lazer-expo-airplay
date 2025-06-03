import Foundation

public enum LazerResult<T, E: Error> {
  case success(T)
  case failure(E)

  public var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }

  public var data: T? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  public var error: E? {
    switch self {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }

  public func toDictionary() -> [String: Any] {
    switch self {
    case .success(let value):
      return [
        "success": true,
        "data": value,
        "error": NSNull(),
      ]
    case .failure(let error):
      return [
        "success": false,
        "data": NSNull(),
        "error": error.localizedDescription,
      ]
    }
  }
}
