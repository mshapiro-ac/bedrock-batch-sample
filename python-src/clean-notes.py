
import re
import json
from dataclasses import dataclass
from typing import List

@dataclass
class CleanedNote:
    note_id: str
    original_text: str
    cleaned_text: str
    warning_messages: List[str]
    is_valid: bool

def clean_notes(notes, max_length=4000):
    cleaned_notes = []
    
    for note in notes:
        note_id = note['note_id']
        original_text = note['note_text']
        warnings = []
        is_valid = True
        
        # Skip empty notes
        if not original_text or original_text.strip() == '':
            warnings.append("Note is empty")
            is_valid = False
            cleaned_notes.append(CleanedNote(
                note_id=note_id,
                original_text=original_text,
                cleaned_text="",
                warning_messages=warnings,
                is_valid=is_valid
            ))
            continue
        
        # Start with the original text
        cleaned_text = original_text
        
        # Trim whitespace
        cleaned_text = cleaned_text.strip()
        
        # Remove HTML tags
        cleaned_text = re.sub(r'<[^>]*>', '', cleaned_text)
        
        # Remove emojis and other special characters
        # This regex keeps alphanumeric chars, basic punctuation, and common symbols
        cleaned_text = re.sub(r'[^\x00-\x7F]+', '', cleaned_text)
        
        # Replace newlines, tabs, and multiple spaces with single spaces
        cleaned_text = re.sub(r'[\r\n\t]+', ' ', cleaned_text)
        cleaned_text = re.sub(r' {2,}', ' ', cleaned_text)
        
        # Check if the text was significantly modified
        if len(original_text) > len(cleaned_text) * 1.2:  # 20% or more reduction
            warnings.append("Significant content was removed during cleaning")
        
        # Limit length if specified
        if max_length and len(cleaned_text) > max_length:
            cleaned_text = cleaned_text[:max_length]
            warnings.append(f"Note was truncated to {max_length} characters")
        
        # Final validation check - ensure there's still content after cleaning
        if not cleaned_text:
            warnings.append("Note became empty after cleaning")
            is_valid = False
        
        cleaned_notes.append(CleanedNote(
            note_id=note_id,
            original_text=original_text,
            cleaned_text=cleaned_text,
            warning_messages=warnings,
            is_valid=is_valid
        ))
    
    return cleaned_notes


