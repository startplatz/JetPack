import JetPack
import UIKit


class LabelTestViewController: ViewController {

	private let label = Label()


	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .black

		let font1 = UIFont(name: "Zapfino", size: 25)!
		let font2 = UIFont(name: "Zapfino", size: 15)!

		let at = NSMutableAttributedString(string: "ABCDEÄji0ABCDEÄji0")
		at.addAttributes([ NSFontAttributeName: font1 ], range: NSRange(location: 0, length: 9))
		at.addAttributes([ NSFontAttributeName: font2 ], range: NSRange(location: 9, length: 9))

		let text = NSMutableAttributedString(string: "")

		label.horizontalAlignment = .left
		label.backgroundColor = .red
		label.lineBreakMode = .byTruncatingTail
		label.maximumNumberOfLines = nil
		label.attributedText = text
		label.font = font1
		label.minimumScaleFactor = 0
		label.textColor = .tintColor()
		label.lineHeightMultiple = 1
		label.linkTapped = { url in
			print("link tapped!")
		}

		var frame = CGRect(left: 30, top: 120, width: 300, height: 50)
		//frame.size.height = label.heightThatFitsWidth(300)
		frame.size = label.sizeThatFitsSize(CGSize(width: 375 - 60, height: 180))
		label.frame = frame

		let pas = NSMutableParagraphStyle()
		pas.alignment = .left
		pas.lineBreakMode = .byWordWrapping
		pas.lineHeightMultiple = 1

		let label2 = UILabel()
		label2.textAlignment = .left
		label2.font = font1
		label2.lineBreakMode = .byWordWrapping
		label2.numberOfLines = 0
		label2.attributedText = NSAttributedString(string: "")
			.withDefaultAttributes(font: label2.font, foregroundColor: nil, kerning: nil, paragraphStyle: pas, transform: nil)
		label2.textColor = .white
		label2.backgroundColor = .red
		label2.minimumScaleFactor = 0
		label2.adjustsFontSizeToFitWidth = true

		var frame2 = CGRect(left: 30, top: 400, width: 300, height: 50)
		frame2.size = label2.sizeThatFitsSize(CGSize(width: 375 - 60, height: 150))
		label2.frame = frame2

		view.addSubview(label)
		view.addSubview(label2)
/*
		let l3 = Label()
		l3.backgroundColor = .red
		l3.font = UIFont.systemFont(ofSize: 17)
		l3.text = "Own Label"
		l3.textColor = .white
		var f3 = CGRect()
		f3.left = 30
		f3.size = l3.sizeThatFits()
		f3.top = 70
		l3.frame = f3*/

		let l4 = UILabel()
		l4.backgroundColor = .red
		l4.text = "iOS UILabel"
		l4.textColor = .white
		var f4 = CGRect()
		f4.left = 30
		f4.size = l4.sizeThatFits()
		f4.top = 370
		l4.frame = f4

		//view.addSubview(l3)
		view.addSubview(l4)

		onMainQueue(after: 2) {
			//self.label.text = "zzz"
			//self.label.frame.size = self.label.sizeThatFits()
		}
	}
}