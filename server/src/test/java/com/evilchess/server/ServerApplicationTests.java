package com.evilchess.server;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** Boots the whole app against real Postgres + Redis containers and checks Flyway ran. */
@Tag("integration")
@Import(TestcontainersConfiguration.class)
@SpringBootTest
class ServerApplicationTests {

	@Autowired
	JdbcTemplate jdbc;

	@Test
	void contextLoadsAndBaselineMigrationRan() {
		String value = jdbc.queryForObject(
				"SELECT value FROM app_meta WHERE key = 'schema_baseline'", String.class);
		assertThat(value).isEqualTo("phase-0");
	}

}
