//
//  WebKitViewController.swift
//  iZambomba
//
//  Created by SingularNet on 27/12/18.
//  Copyright © 2018 SingularNet. All rights reserved.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadHTMLString("<div style='width:100%;padding-top:64%;position:relative;border-bottom:1px solid #aaa;display:inline-block;background:#eee;background:rgba(255,255,255,0.9);'>    <iframe frameborder='0' src='http://www.rtve.es/drmn/embed/video/3410362' name='¿Un membranófono de fricción?' scrolling='no' style='width:100%;height:90%;position:absolute;left:0;top:0;overflow:hidden;' allowfullscreen></iframe>    <div style='position:absolute;bottom:0;left:0;font-family:arial,helvetica,sans-serif;font-size:12px;line-height:1.833;display:inline-block;padding:5px 0 5px 10px;'>        <span style='float:left;margin-right:10px'>            <img style='height:20px;width:auto;background: transparent;padding:0;margin:0;' src='http://img.irtve.es/css/rtve.commons/rtve.header.footer/i/logoRTVEes.png'>        </span>           <a style='color:#333;font-weight:bold;' title='¿Un membranófono de fricción?' href='http://www.rtve.es/alacarta/videos/aqui-la-tierra/aqui-tierra-mebranofono-friccion/3410362/'>            <strong>¿Un membranófono de fricción?</strong>        </a>    </div></div>", baseURL: nil)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
