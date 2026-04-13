package com.colorin.app

import android.content.Context
import com.colorin.core.data.CatalogRepository
import com.colorin.core.data.AssetCatalogRepository
import com.colorin.core.data.PaintProgressRepository
import com.colorin.core.data.SharedPreferencesPaintProgressRepository

class AppContainer(context: Context) {
    val catalogRepository: CatalogRepository = AssetCatalogRepository(context)
    val paintProgressRepository: PaintProgressRepository =
        SharedPreferencesPaintProgressRepository(context)
}
