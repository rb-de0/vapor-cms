import Vapor

class ArticleRegisterController: Controller {
    
    typealias Item = String
    
    private weak var application: Application!
    
    required init(application: Application) {
        self.application = application
    }
    
    func index(request: Request) throws -> ResponseRepresentable {

        guard SessionManager.hasSession(request: request) else{
            let response = Response(redirect: "/login")
            return response
        }

        SecureUtil.setAuthenticityToken(application: application, request: request)

        return try self.application.view("article-register.mustache", context: ViewUtil.contextIncludeHeader(request: request, context: [:]))
    }

    func store(request: Request) throws -> ResponseRepresentable {

        guard SecureUtil.verifyAuthenticityToken(application: application, request: request) else{
            return "Invalid request"
        }

        guard SessionManager.hasSession(request: request) else{
            return Response(redirect: "/")
        }

        var errorMessage = ""
        var successMessage = ""

        do{
            let articleInput = try ArticleInput(request: request)
            let result = ArticleAccessor.register(input: articleInput)

            (errorMessage, successMessage) = result ? ("", "登録しました") : ("登録失敗しました", "")
        }catch let validationError as ValidationErrorProtocol{

            (errorMessage, successMessage) = (validationError.message, "")            
        }

        let context: [String: Any] = [
            "title": request.data["title"].string ?? "",
            "content": request.data["content"].string ?? "",
            "error_message": errorMessage, 
            "success_message": successMessage
        ]
        return try self.application.view("article-register.mustache", context: ViewUtil.contextIncludeHeader(request: request, context: context))
    }
}