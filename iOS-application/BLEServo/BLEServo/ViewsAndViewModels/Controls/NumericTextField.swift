import UIKit

class NumericTextField: UITextField {
    let numericKbdToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))

    // MARK: Initilization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    // Sets up the input accessory view with a Done button that closes the keyboard
    func initialize() {
        keyboardType = .decimalPad

        numericKbdToolbar.barStyle = UIBarStyle.default
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let callback = #selector(NumericTextField.finishedEditing)
        let buttonDone = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: callback)
        numericKbdToolbar.setItems([space, buttonDone], animated: false)
        numericKbdToolbar.sizeToFit()
        inputAccessoryView = numericKbdToolbar
    }

    // MARK: On Finished Editing Function
    @objc
    func finishedEditing() {
        resignFirstResponder()
    }
}
