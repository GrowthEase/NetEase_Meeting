// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SDWebImage

@objcMembers public class NEMeetingAvatar: UIView {
  /// 头像昵称
  public var name: String? {
    didSet {
      let style = dealName()
      label.text = style.0
      label.font = UIFont.boldSystemFont(ofSize: CGFloat(style.1))
      imageView.isHidden = (url == nil || url!.isEmpty)
      if !imageView.isHidden {
        label.isHidden = true
      } else {
        label.isHidden = (name == nil || name!.isEmpty)
      }
    }
  }

  /// 头像地址
  public var url: String? {
    didSet {
      if let urlStr = url,
         let url = URL(string: urlStr) {
        imageView.sd_setImage(with: url)
      }
      imageView.isHidden = (url == nil || url!.isEmpty)
      if !imageView.isHidden {
        label.isHidden = true
      } else {
        label.isHidden = (name == nil || name!.isEmpty)
      }
    }
  }

  func dealName() -> (String?, Float) {
    var fontSize: Float = 0
    if var name = name {
      var chinese = [String]()
      var letters = [String]()
      var digits = [String]()

      for value in name {
        if isChinese(value) {
          chinese.append(String(value))
        } else if value.isLetter {
          letters.append(String(value))
        } else if value.isHexDigit {
          digits.append(String(value))
        }
      }
      if !chinese.isEmpty {
        fontSize = chinese.count >= 2 ? 28 : 32
        name = chinese.suffix(2).joined()
      } else if !letters.isEmpty {
        if let firstLetter = letters.first {
          letters[0] = firstLetter.uppercased()
        }
        fontSize = 30
        name = letters.prefix(2).joined()
      } else if !digits.isEmpty {
        fontSize = 30
        name = digits.suffix(2).joined()
      } else {
        fontSize = 32
        name = "*"
      }
      fontSize = Float(bounds.width / 100) * fontSize
      return (name, fontSize)
    }
    return (nil, fontSize)
  }

  func isChinese(_ value: Character) -> Bool {
    let scalarValue = value.unicodeScalars.first!.value
    return (scalarValue >= 0x4E00 && scalarValue <= 0x9FFF)
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    layer.insertSublayer(gradientLayer, at: 0)
    addSubview(imageView)
    addSubview(label)
  }

  lazy var gradientLayer: CAGradientLayer = {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor(red: 89 / 255, green: 150 / 255, blue: 255 / 255, alpha: 1.0).cgColor, UIColor(red: 37 / 255, green: 117 / 255, blue: 255 / 255, alpha: 1.0).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    return gradientLayer
  }()

  override public var frame: CGRect {
    didSet {
      gradientLayer.frame = bounds
      imageView.frame = bounds
      label.frame = bounds
      /// 更新一下fontsize
      let style = dealName()
      label.text = style.0
      label.font = UIFont.boldSystemFont(ofSize: CGFloat(style.1))
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var imageView: UIImageView = .init()

  lazy var label: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.white
    label.textAlignment = .center
    return label
  }()
}
