//
//  TabBarVisibility.swift
//  Stitchery
//
//  Created by Ethan Thomas on 9/16/26.
//

import SwiftUI

/// Shared, observable flag that lets deep screens (e.g. an active chat) hide the
/// custom tab bar to reclaim space for typing. Injected into the environment by
/// `TabNavigation` and toggled by whichever screen wants the bar hidden.
@Observable
final class TabBarVisibility {
    var isHidden = false
}
