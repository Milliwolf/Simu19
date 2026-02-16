import pandas as pd
import numpy as np

def create_building_electric_profile():
    hours = pd.date_range(start="2024-01-01", periods=8760, freq="H")
    
    sorter_load = []
    lighting_it_load = []
    
    for h in hours:
        hour = h.hour
        is_weekend = h.weekday() >= 5
        
        # --- SORTIERANLAGE (6000 Pakete/h) ---
        # Hauptbetriebszeiten bei Express: Frühmorgens und Spätnachmittags
        if not is_weekend and (5 <= hour <= 9 or 16 <= hour <= 20):
            s_power = 75.0 # Volllast in kW
        elif not is_weekend and (10 <= hour <= 15):
            s_power = 15.0 # Teillast/Vorsortierung
        else:
            s_power = 2.0  # Standby
            
        # --- BELEUCHTUNG & IT ---
        # Halle & Büro (5500m2 @ 7W/m2 ca. 38kW)
        if 6 <= hour <= 20:
            l_power = 38.0 # Hauptarbeitszeit
        else:
            l_power = 12.0 # Nacht/Sicherheit/Server-Grundlast
            
        if is_weekend:
            l_power *= 0.4 # Reduziert am Wochenende
            
        sorter_load.append(s_power)
        lighting_it_load.append(l_power)
        
    df = pd.DataFrame({
        'Sortieranlage_kW': sorter_load,
        'Licht_IT_kW': lighting_it_load,
        'Gebaeude_Strom_Gesamt_kW': np.array(sorter_load) + np.array(lighting_it_load)
    }, index=hours)
    
    df.to_csv("dhl_marsdorf_elektronik.csv")
    print("Datei 'dhl_marsdorf_elektronik.csv' wurde erstellt!")

create_building_electric_profile()