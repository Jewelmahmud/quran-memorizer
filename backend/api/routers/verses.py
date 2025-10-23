"""
Verses router for Quran text and metadata
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter()

class Verse(BaseModel):
    surah_id: int
    ayah_id: int
    text: str
    translation: Optional[str] = None
    transliteration: Optional[str] = None
    juz: Optional[int] = None

class Surah(BaseModel):
    surah_id: int
    name: str
    name_transliterated: str
    ayah_count: int
    juz: Optional[int] = None

@router.get("/{surah_id}/{ayah_id}", response_model=Verse)
async def get_verse(surah_id: int, ayah_id: int):
    """
    Get a specific verse by surah and ayah ID
    """
    # TODO: Implement database query for verse
    # For now, return mock data
    if surah_id < 1 or surah_id > 114 or ayah_id < 1:
        raise HTTPException(status_code=404, detail="Verse not found")
    
    return Verse(
        surah_id=surah_id,
        ayah_id=ayah_id,
        text="بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        translation="In the name of Allah, the Entirely Merciful, the Especially Merciful",
        transliteration="Bismillahi ar-Rahman ar-Raheem"
    )

@router.get("/surah/{surah_id}", response_model=List[Verse])
async def get_surah(surah_id: int):
    """
    Get all verses of a surah
    """
    # TODO: Implement database query for entire surah
    if surah_id < 1 or surah_id > 114:
        raise HTTPException(status_code=404, detail="Surah not found")
    
    # Mock data - return first few verses
    verses = []
    for ayah_id in range(1, 8):  # First 7 verses as example
        verses.append(Verse(
            surah_id=surah_id,
            ayah_id=ayah_id,
            text=f"Verse {ayah_id} of Surah {surah_id}",
            translation=f"Translation of verse {ayah_id}",
            transliteration=f"Transliteration of verse {ayah_id}"
        ))
    
    return verses

@router.get("/surahs", response_model=List[Surah])
async def get_all_surahs():
    """
    Get list of all surahs
    """
    # TODO: Implement database query for surahs metadata
    # Return first few surahs as example
    surahs = [
        Surah(surah_id=1, name="Al-Fatiha", name_transliterated="Al-Fatiha", ayah_count=7, juz=1),
        Surah(surah_id=2, name="Al-Baqarah", name_transliterated="Al-Baqarah", ayah_count=286, juz=1),
        Surah(surah_id=3, name="Ali 'Imran", name_transliterated="Ali 'Imran", ayah_count=200, juz=2),
    ]
    return surahs
