package com.evilchess.server.meta;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import com.evilchess.server.config.RateLimitFilter;
import com.evilchess.server.config.SecurityConfig;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(MetaController.class)
@Import({SecurityConfig.class, RateLimitFilter.class})
class MetaControllerTest {

    @Autowired
    MockMvc mvc;

    @Test
    void returnsNameAndApiVersion() throws Exception {
        mvc.perform(get("/api/v1/meta"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("evilchess"))
                .andExpect(jsonPath("$.apiVersion").value(MetaController.API_VERSION));
    }
}
