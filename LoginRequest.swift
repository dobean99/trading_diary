import Foundation

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}