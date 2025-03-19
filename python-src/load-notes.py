import csv

def load_notes_from_csv(file_path):
    
    notes = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                notes.append({
                    'note_id': row['note_id'],
                    'note_text': row['note_text']
                })
        return notes
    except Exception as e:
        print(f"Error loading notes: {e}")
        return []
    
def load_notes_from_query(database_connection, query):
    
    notes = []
    
    """
    Load notes from a database query of notes
    """

    return notes; 

def load_notes_from_json(json_file_path):
    
    notes = []
    
    """
    Load notes from a json file
    """

    return notes; 