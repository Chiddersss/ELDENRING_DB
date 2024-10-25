CREATE TABLE character_classes (
    class_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    starting_level INTEGER NOT NULL
);

CREATE TABLE builds (
    build_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class_id INTEGER,
    level INTEGER NOT NULL,
    runes_required INTEGER,
    play_style VARCHAR(50),
    build_type VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_url TEXT,
    upvotes INTEGER DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (class_id) REFERENCES character_classes(class_id)
);

CREATE TABLE attributes(
    build_id INTEGER,
    vigor INTEGER NOT NULL DEFAULT 10,
    mind INTEGER NOT NULL DEFAULT 10,
    endurance INTEGER NOT NULL DEFAULT 10,
    strength INTEGER NOT NULL DEFAULT 10,
    dexterity INTEGER NOT NULL DEFAULT 10,
    intelligence INTEGER NOT NULL DEFAULT 10,
    faith INTEGER NOT NULL DEFAULT 10,
    arcane INTEGER NOT NULL DEFAULT 10,
    FOREIGN KEY (build_id) REFERENCES builds(build_id),
    PRIMARY KEY (build_id)
);

CREATE TABLE weapons (
    weapon_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    weapon_type VARCHAR(50) NOT NULL,
    weight DECIMAL(5,1),
    requires_strength INTEGER DEFAULT 0,
    requires_dexterity INTEGER DEFAULT 0,
    requires_intelligence INTEGER DEFAULT 0,
    requires_faith INTEGER DEFAULT 0,
    requires_arcane INTEGER DEFAULT 0,
    damage_type VARCHAR(50),
    upgrade_type VARCHAR(50) 
);

CREATE TABLE armor (
    armor_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    armor_type VARCHAR(50) NOT NULL, 
    weight DECIMAL(5,1),                 -- named weight_id as
    physical_defense DECIMAL(5,1),
    magic_defense DECIMAL(5,1),
    fire_defense DECIMAL(5,1),
    lightning_defense DECIMAL(5,1),
    holy_defense DECIMAL(5,1),
    poise DECIMAL(5,1)
);

CREATE TABLE tailsman (
    tailsman_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    effect TEXT,
    weight DECIMAL(5,1)
);

CREATE TABLE spells (
    spell_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    spell_type VARCHAR(50),
    requires_intelligence INTEGER DEFAULT 0,
    requires_faith INTEGER DEFAULT 0,
    fp_cost INTEGER,
    slots_required INTEGER DEFAULT 1
);

-- Create junction tables for many to many relationships
CREATE TABLE build_armor (
    build_id INTEGER,
    armor INTEGER,
    slot VARCHAR(20) NOT NULL,
    FOREIGN KEY (build_id) REFERENCES builds(build_id),
    FOREIGN KEY (armor_id) REFERENCES armor(armor_id),
    PRIMARY KEY (build_id, armor_id)
);

CREATE TABLE build_tailsman (
    build_id INTEGER,
    tailsman_id INTEGER,
    slot_number INTEGER NOT NULL CHECK (slot_number BETWEEN 1 AND 4),
    FOREIGN KEY (build_id) REFERENCES builds(build_id),
    FOREIGN KEY (tailsman_id) REFERENCES tailsman(tailsman_id),
    PRIMARY KEY (build_id, tailsman_id)
);

CREATE TABLE build_spells (
    build_id INTEGER,
    spell_id INTEGER,
    slot_number INTEGER NOT NULL,
    FOREIGN KEY (build_id) REFERENCES builds(build_id),
    FOREIGN KEY (spell_id) REFERENCES spells(spell_id),
    PRIMARY KEY (build_id, spell_id)
);

CREATE INDEX idx_builds_level ON builds(level);
CREATE INDEX idx_builds_play_style ON builds(play_style);
CREATE INDEX idx_builds_build_type ON builds(builds_type);
CREATE INDEX idx_weapons_requirments ON weapons(requires_strength, requires_dexterity, requires_intelligence, requires_faith, requires_arcane);

CREATE VIEW v_complete_builds AS 
SELECT 
    b.build_id,
    b.name AS build_name,
    b.level,
    b.play_syle,
    b.build_type,
    c.name AS class_name,
    a.vigor,
    a.mind,
    a.endurance,
    a.strength,
    a.dexterity,
    a.intelligence,
    a.faith,
    a.arcane
FROM builds b
JOIN attributes a ON b.build_id = a.build_id
LEFT JOIN character_classes c ON b.class_id = c.class_id;

-- -- Example queries
-- -- Find builds by level range and play style
-- CREATE VIEW v_pvp_meta_builds AS
-- SELECT *
-- FROM v_complete_builds
-- WHERE level BETWEEN 120 AND 150
-- AND play_style = 'PvP'
-- ORDER BY upvotes DESC;

CREATE VIEW v_pvp_meta_builds AS
SELECT * 
FROM v_complete_builds
WHERE level BETWEEN 120 AND 150
AND play_style = 'pvp'
ORDER BY upvotes DESC;

CREATE VIEW v_build_equipments AS
SELECT
    b.build_id,
    b.name AS build_name,
    w.name AS weapon_name,
    bw.upgrade_level AS weapon_upgrade,
    a.name AS armor_name,
    ba.slot AS aromr_slot,
    t.name AS tailsman_name,
    s.name AS spell_name
FROM builds ba
LEFT JOIN build_weapons bw ON b.build_id = bw.build_id
LEFT JOIN weapons w ON bw.weapon_id = w.weapon_id
LEFT JOIN build_armor ba ON b.build_id = ba.build_id
LEFT JOIN armor a ON ba.armor_id = a.armor_id
LEFT JOIN build_talismans bt ON b.build_id = bt.build_id
LEFT JOIN talismans t ON bt.talisman_id = t.talisman_id
LEFT JOIN build_spells bs ON b.build_id = bs.build_id
LEFT JOIN spells s ON bs.spell_id = s.spell_id;