//
//  VoteTableViewCell.swift
//  Wallet
//
//  Created by Maynard on 2018/5/8.
//  Copyright © 2018年 New Horizon Labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VoteTableViewCell: UITableViewCell {

    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var websiteLabel: WebsiteLabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var voteNumberLabel: UILabel!
    var model: Witness?
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        ServiceHelper.shared.isWatchMode.asObservable()
//            .bind(to: voteButton.rx.isHidden)
//            .disposed(by: disposeBag)
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            super.setSelected(false, animated: true)
        }
        // Configure the view for the selected state
    }
    
    func configureUI() {
        addressTitleLabel.text = R.string.tron.voteAddressLabelTitle()
    }
    
    func configure(model: Witness, voteArray: [Vote]) {
        self.model = model
        addressLabel.text = model.address.addressString
        voteNumberLabel.text = String(model.voteCount)
        websiteLabel.text = model.url
        websiteLabel.textColor = UIColor.mainNormalColor
        websiteLabel.url = URL(string: model.url)

        if let vote = (voteArray.filter { (object) -> Bool in
            return object.voteAddress.addressString == model.address.addressString
        }).first {
            inputTextField.text = vote.voteCount.string
//            voteNumberTitleLabel.text = R.string.tron.voteYourvoteLabelTitle()
//            voteNumberTitleLabel.isHidden = false
           
        } else {
            inputTextField.text = ""
//            voteNumberTitleLabel.isHidden = true
            
        }
        
        (inputTextField.rx.text).skip(1).map({ (text) -> Int64 in
            return Int64(text ?? "0") ?? 0
        }).asObservable()
            .subscribe(onNext: { (number) in
                let vote = Vote()
                vote.voteAddress = model.address
                vote.voteCount = number
                ServiceHelper.shared.voteModelChange.onNext(vote)
            })
        .disposed(by: disposeBag)
        let a = TronAccount()
        a.address = model.address
        ServiceHelper.shared.getAccount(account: a)
        .asObservable()
            .subscribe(onNext: {[weak self] (account) in
                if let name = account.accountName.toString()?.emptyToNil() {
                    self?.websiteLabel.text = name
                } else {
                    self?.websiteLabel.text = model.url
                }
            })
        .disposed(by: disposeBag)
    }
    
    @objc func buttonClick() {
        let voteView = VoteInputView.loadXib()
        voteView.model = model
        voteView.popShow()
        voteView.successBlock = {[weak self] number in
            self?.votedSuccess(number: number)
        }
    }
    
    func votedSuccess(number: Int64) {
        if let model = model {
            model.voteCount = model.voteCount + number
//            configure(model: model)
        }
    }
}
