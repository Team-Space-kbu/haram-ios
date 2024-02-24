//
//  RevisionOfTranslationModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/22.
//

import Foundation

struct RevisionOfTranslationModel {
  let bibleName: String
  let chapter: Int64
  let jeol: Int64
  let id: Int64
  
  init(bibleName: String, chapter: Int64, jeol: Int64, id: Int64) {
    self.bibleName = bibleName
    self.chapter = chapter
    self.jeol = jeol
    self.id = id
  }
  
  init(revisionOfTranslation: RevisionOfTranslation) {
    bibleName = revisionOfTranslation.bibleName
    chapter = revisionOfTranslation.chapter
    jeol = revisionOfTranslation.jeol
    id = revisionOfTranslation.id
  }
}
