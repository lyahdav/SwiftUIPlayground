struct Toast {
    let text: String
    let imageName: String
    
    init(text: String, imageName: String) {
        self.text = text
        self.imageName = imageName
    }
    
    static let errorSavingToast = Toast(text: "Error saving tasks!", imageName: "exclamationmark.triangle.fill")
    static let successSavingToast = Toast(text: "Tasks saved", imageName: "checkmark.square.fill")
}
