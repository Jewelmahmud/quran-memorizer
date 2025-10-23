"""
Data downloader for Quran text and audio files
"""

import requests
import os
import json
import xml.etree.ElementTree as ET
from typing import Dict, List, Optional
import zipfile
from urllib.parse import urljoin
import time

class QuranDataDownloader:
    """
    Downloads Quran text and audio data from various sources
    """
    
    def __init__(self, data_dir: str = "backend/data"):
        self.data_dir = data_dir
        self.quran_text_dir = os.path.join(data_dir, "quran_text")
        self.audio_dir = os.path.join(data_dir, "audio")
        self.preprocessing_dir = os.path.join(data_dir, "preprocessing")
        
        # Create directories
        for dir_path in [self.quran_text_dir, self.audio_dir, self.preprocessing_dir]:
            os.makedirs(dir_path, exist_ok=True)
    
    def download_tanzil_quran_text(self, language: str = "en") -> str:
        """
        Download Quran text from Tanzil.net
        
        Args:
            language: Language code for translation (en, ar, etc.)
            
        Returns:
            Path to downloaded file
        """
        # Tanzil API endpoint
        base_url = "http://tanzil.net/trans/"
        translation_url = f"{base_url}trans/{language}.trans.xml"
        
        try:
            print(f"Downloading Quran text in {language} from Tanzil...")
            response = requests.get(translation_url, timeout=30)
            response.raise_for_status()
            
            # Save raw XML
            xml_path = os.path.join(self.quran_text_dir, f"quran_{language}.xml")
            with open(xml_path, 'w', encoding='utf-8') as f:
                f.write(response.text)
            
            # Parse and convert to JSON
            json_path = self._parse_tanzil_xml_to_json(xml_path, language)
            
            print(f"Downloaded Quran text to {json_path}")
            return json_path
            
        except requests.RequestException as e:
            print(f"Error downloading from Tanzil: {e}")
            return None
    
    def _parse_tanzil_xml_to_json(self, xml_path: str, language: str) -> str:
        """
        Parse Tanzil XML to structured JSON
        """
        tree = ET.parse(xml_path)
        root = tree.getroot()
        
        quran_data = {
            "metadata": {
                "source": "tanzil.net",
                "language": language,
                "downloaded_at": time.strftime("%Y-%m-%d %H:%M:%S")
            },
            "surahs": []
        }
        
        for surah in root.findall('.//sura'):
            surah_id = int(surah.get('index'))
            surah_name = surah.get('name')
            ayah_count = int(surah.get('ayas'))
            
            surah_data = {
                "surah_id": surah_id,
                "name": surah_name,
                "ayah_count": ayah_count,
                "verses": []
            }
            
            for ayah in surah.findall('aya'):
                ayah_id = int(ayah.get('index'))
                text = ayah.text.strip() if ayah.text else ""
                
                verse_data = {
                    "ayah_id": ayah_id,
                    "text": text,
                    "juz": self._get_juz_number(surah_id, ayah_id)
                }
                
                surah_data["verses"].append(verse_data)
            
            quran_data["surahs"].append(surah_data)
        
        # Save JSON
        json_path = os.path.join(self.quran_text_dir, f"quran_{language}.json")
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(quran_data, f, ensure_ascii=False, indent=2)
        
        return json_path
    
    def _get_juz_number(self, surah_id: int, ayah_id: int) -> int:
        """
        Calculate Juz (Para) number for a given surah and ayah
        """
        # Juz boundaries (simplified)
        juz_boundaries = [
            (1, 1), (2, 141), (2, 252), (3, 92), (4, 23),
            (4, 147), (5, 81), (6, 110), (7, 87), (8, 40),
            (9, 92), (10, 109), (11, 5), (12, 52), (13, 15),
            (16, 128), (18, 74), (20, 135), (22, 78), (25, 20),
            (27, 55), (29, 45), (33, 30), (36, 27), (39, 31),
            (41, 46), (45, 37), (51, 30), (57, 29), (67, 26)
        ]
        
        for i, (s_id, a_id) in enumerate(juz_boundaries):
            if surah_id < s_id or (surah_id == s_id and ayah_id <= a_id):
                return i + 1
        
        return 30  # Last juz
    
    def download_everyayah_audio(self, reciters: List[str] = None) -> Dict[str, str]:
        """
        Download audio files from EveryAyah.com
        
        Args:
            reciters: List of reciter IDs to download
            
        Returns:
            Dictionary mapping reciter to download directory
        """
        if reciters is None:
            reciters = ["mishary_rashid_alafasy", "abdul_basit_murattal"]
        
        base_url = "https://everyayah.com/data/"
        downloaded_paths = {}
        
        for reciter in reciters:
            print(f"Downloading audio for reciter: {reciter}")
            reciter_dir = os.path.join(self.audio_dir, reciter)
            os.makedirs(reciter_dir, exist_ok=True)
            
            # Download a few surahs as example (start with Al-Fatiha)
            surahs_to_download = [1, 2, 3]  # First 3 surahs
            
            for surah_id in surahs_to_download:
                surah_dir = os.path.join(reciter_dir, f"surah_{surah_id:03d}")
                os.makedirs(surah_dir, exist_ok=True)
                
                # Download individual ayah files
                for ayah_id in range(1, 8):  # First 7 ayahs as example
                    audio_filename = f"{surah_id:03d}{ayah_id:03d}.mp3"
                    audio_url = f"{base_url}{reciter}/{surah_id:03d}{ayah_id:03d}.mp3"
                    
                    try:
                        response = requests.get(audio_url, timeout=10)
                        if response.status_code == 200:
                            audio_path = os.path.join(surah_dir, audio_filename)
                            with open(audio_path, 'wb') as f:
                                f.write(response.content)
                            print(f"Downloaded: {audio_filename}")
                        else:
                            print(f"Failed to download: {audio_filename}")
                        
                        time.sleep(0.1)  # Rate limiting
                        
                    except requests.RequestException as e:
                        print(f"Error downloading {audio_filename}: {e}")
            
            downloaded_paths[reciter] = reciter_dir
        
        return downloaded_paths
    
    def download_tarteel_dataset(self) -> str:
        """
        Download Tarteel dataset for AI training
        
        Returns:
            Path to downloaded dataset directory
        """
        # Note: Tarteel dataset may require special access
        # This is a placeholder for the actual download process
        tarteel_dir = os.path.join(self.data_dir, "tarteel_dataset")
        os.makedirs(tarteel_dir, exist_ok=True)
        
        print("Tarteel dataset download not implemented yet.")
        print("Please manually download from: https://github.com/Tarteel-io/tarteel-dataset")
        
        return tarteel_dir
    
    def create_metadata_file(self) -> str:
        """
        Create metadata file for all downloaded data
        
        Returns:
            Path to metadata file
        """
        metadata = {
            "download_info": {
                "downloaded_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "sources": {
                    "quran_text": "tanzil.net",
                    "audio": "everyayah.com",
                    "tarteel": "tarteel.ai (manual download required)"
                }
            },
            "files": {
                "quran_text": [],
                "audio": [],
                "preprocessing": []
            }
        }
        
        # Scan for downloaded files
        for root, dirs, files in os.walk(self.data_dir):
            for file in files:
                rel_path = os.path.relpath(os.path.join(root, file), self.data_dir)
                
                if "quran_text" in rel_path:
                    metadata["files"]["quran_text"].append(rel_path)
                elif "audio" in rel_path:
                    metadata["files"]["audio"].append(rel_path)
                elif "preprocessing" in rel_path:
                    metadata["files"]["preprocessing"].append(rel_path)
        
        # Save metadata
        metadata_path = os.path.join(self.data_dir, "metadata.json")
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, ensure_ascii=False, indent=2)
        
        return metadata_path

def main():
    """
    Main function to download all data
    """
    downloader = QuranDataDownloader()
    
    print("Starting Quran data download...")
    
    # Download Quran text
    print("\n1. Downloading Quran text...")
    arabic_text = downloader.download_tanzil_quran_text("ar")
    english_text = downloader.download_tanzil_quran_text("en")
    
    # Download audio files
    print("\n2. Downloading audio files...")
    audio_paths = downloader.download_everyayah_audio()
    
    # Download Tarteel dataset
    print("\n3. Tarteel dataset...")
    tarteel_path = downloader.download_tarteel_dataset()
    
    # Create metadata
    print("\n4. Creating metadata...")
    metadata_path = downloader.create_metadata_file()
    
    print(f"\nDownload complete! Metadata saved to: {metadata_path}")

if __name__ == "__main__":
    main()
