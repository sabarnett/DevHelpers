//
// File: EnumPicker.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct EnumPicker<Enum, Label, Content>: View where Enum: CaseIterable & Equatable, Enum.AllCases.Index: Hashable, Label: View, Content: View {
    let selection: Binding<Enum>
    @ViewBuilder let content: (Enum) -> Content
    @ViewBuilder let label: () -> Label

    var body: some View {
        Picker(selection: selection.caseIndex) { // swiftlint:disable:this multiline_arguments
            ForEach(Array(Enum.allCases).indexed(), id: \.0) { index, element in
                content(element)
                    .tag(index)
            }
        } label: {
            label()
        }
    }
}

extension EnumPicker where Label == Text {
    init(
        _ title: some StringProtocol,
        selection: Binding<Enum>,
        @ViewBuilder content: @escaping (Enum) -> Content
    ) {
        self.selection = selection
        self.content = content
        self.label = { Text(title) }
    }
}
