//
//  ViewController.swift
//  SDL2.Swift
//
//  Created by Dream on 2021/6/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        SDL_Init(SDL_INIT_AUDIO)
        var version = SDL_version()
        print("\(version.major).\(version.minor).\(version.patch)")
        SDL_GetVersion(&version)
        print("\(version.major).\(version.minor).\(version.patch)")
    }
}

