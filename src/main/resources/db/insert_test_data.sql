INSERT INTO roles (role_name)
VALUES ('SUPER_ADMIN'),
    ('GAME_MASTER'),
    ('MODERATOR');
INSERT INTO roles (role_name)
VALUES ('ROLE_ADMIN'),
    ('ROLE_USER');
INSERT INTO users (username, password, email)
VALUES (
        'admin',
        '$2a$10$1l9/rItLk7SlKwNRdCeKxezrdM3L.tQd3p7ZEK5IFz0JUzBNx9zsy',
        'admin@example.com'
    );
INSERT INTO user_roles (user_id, role_id)
VALUES (1, 1);
INSERT INTO users (username, password, email)
VALUES (
        'superadmin',
        '$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        'superadmin@example.com'
    ),
    (
        'gamemaster',
        '$2a$10$YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY',
        'gamemaster@example.com'
    ),
    (
        'moderator',
        '$2a$10$ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ',
        'moderator@example.com'
    );
INSERT INTO user_roles (user_id, role_id)
VALUES (
        (
            SELECT id
            FROM users
            WHERE username = 'superadmin'
        ),
        (
            SELECT id
            FROM roles
            WHERE role_name = 'SUPER_ADMIN'
        )
    ),
    (
        (
            SELECT id
            FROM users
            WHERE username = 'gamemaster'
        ),
        (
            SELECT id
            FROM roles
            WHERE role_name = 'GAME_MASTER'
        )
    ),
    (
        (
            SELECT id
            FROM users
            WHERE username = 'moderator'
        ),
        (
            SELECT id
            FROM roles
            WHERE role_name = 'MODERATOR'
        )
    );
INSERT INTO guilds (name)
VALUES ('KnightsOfCode'),
    ('DragonsFire');
INSERT INTO players (username, level, guild_id)
VALUES (
        'PlayerOne',
        10,
        (
            SELECT id
            FROM guilds
            WHERE name = 'KnightsOfCode'
        )
    ),
    (
        'PlayerTwo',
        5,
        (
            SELECT id
            FROM guilds
            WHERE name = 'DragonsFire'
        )
    );
INSERT INTO audit_logs (user_id, action, entity, entity_id, details)
VALUES (
        (
            SELECT id
            FROM users
            WHERE username = 'superadmin'
        ),
        'CREATE_PLAYER',
        'players',
        (
            SELECT id
            FROM players
            WHERE username = 'PlayerOne'
        ),
        'Created player PlayerOne with level 10'
    );
INSERT INTO bans (player_id, banned_by, reason, is_permanent)
VALUES (
        (
            SELECT id
            FROM players
            WHERE username = 'PlayerTwo'
        ),
        (
            SELECT id
            FROM users
            WHERE username = 'moderator'
        ),
        'Cheating',
        TRUE
    );