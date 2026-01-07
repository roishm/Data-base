

CREATE TABLE school (
    sid BIGSERIAL PRIMARY KEY,
    sname TEXT NOT NULL
);

CREATE TABLE grade (
    gid BIGSERIAL PRIMARY KEY,
    sid BIGINT NOT NULL,
    gname TEXT NOT NULL,
    
    CONSTRAINT fk_school
        FOREIGN KEY (sid)
        REFERENCES school(sid)
        ON DELETE CASCADE
);

CREATE INDEX idx_classes_school_id ON grade(sid);

CREATE TABLE equipment (
    eid BIGSERIAL PRIMARY KEY,
    ename TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL DEFAULT 1 CHECK (price >= 0)
);

CREATE TABLE requirement (
    rid BIGSERIAL PRIMARY KEY,
    gid BIGINT NOT NULL,
    eid BIGINT NOT NULL,
    quantity BIGINT NOT NULL CHECK (quantity > 0),

    CONSTRAINT fk_grade
        FOREIGN KEY(gid)
        REFERENCES grade(gid)
        ON DELETE CASCADE,

    CONSTRAINT fk_equipment
        FOREIGN KEY(eid)
        REFERENCES equipment(eid)
        ON DELETE CASCADE,

    CONSTRAINT unq_grade_equipment UNIQUE (gid, eid)
);

CREATE INDEX idx_requirement_grade_id ON requirement(gid);

CREATE TABLE users (
    uid BIGSERIAL PRIMARY KEY,
    uname TEXT NOT NULL,
    password TEXT NOT NULL
);

CREATE TABLE cartEntry (
    ceid BIGSERIAL PRIMARY KEY,
    gid BIGINT NOT NULL,
    uid BIGINT NOT NULL,

    CONSTRAINT fk_grade
        FOREIGN KEY(gid)
        REFERENCES grade(gid)
        ON DELETE CASCADE,

    CONSTRAINT fk_user
        FOREIGN KEY(uid)
        REFERENCES users(uid)
        ON DELETE CASCADE

);

CREATE TABLE apply (
    aid BIGSERIAL PRIMARY KEY,
    eid BIGINT NOT NULL,
    ceid BIGINT NOT NULL,

    CONSTRAINT fk_cartentry
        FOREIGN KEY(ceid)
        REFERENCES cartEntry(ceid)
        ON DELETE CASCADE,

    CONSTRAINT fk_equipment
        FOREIGN KEY(eid)
        REFERENCES equipment(eid)
        ON DELETE CASCADE
);
