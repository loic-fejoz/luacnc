/**
 * Copyright (c) 2014 Loïc Fejoz
 * This file is provided under the MIT License.
 * author(s):
 *  - Loïc Fejoz <loic@fejoz.net>
 */
#include <errno.h>
#include <stdbool.h>
#include <assert.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <GL/glew.h>
#include <GL/freeglut.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <sys/inotify.h>
#include <sys/epoll.h>
 
#define PROGRAM_NAME "luacnc"
#define NAME_MAX (1024)
#define EVENT_BUF_LEN  (sizeof(struct inotify_event) + NAME_MAX + 1)

GLuint program;
GLint attribute_coord2d;
int inotify_fd;
char* script_filename;
const char* fragment_shader_source;
double default_depth;

bool init_resources(const char* fragment_shader_source_without_header, double default_depth) {
  GLint 
    compile_ok = GL_FALSE, 
    link_ok = GL_FALSE;
 
  GLuint vs = glCreateShader(GL_VERTEX_SHADER);
  const char *vs_source = 
    "#version 120\n"  // OpenGL 2.1
    "attribute vec2 coord2d;                  "
    "void main(void) {                        "
    "  gl_Position = vec4(coord2d, 0.0, 1.0); "
    "}";
  glShaderSource(vs, 1, &vs_source, NULL);
  glCompileShader(vs);
  glGetShaderiv(vs, GL_COMPILE_STATUS, &compile_ok);
  if (0 == compile_ok)
  {
    fprintf(stderr, "Error in vertex shader\n");
    return false;
  }
  GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
  const char* header_fmt = "#version 120\nvoid main(void) {\n gl_FragColor[0] = %.3lf;\n gl_FragColor[1] = %.3lf;\n gl_FragColor[2] = %.3lf;\n vec2 coord = gl_FragCoord.xy;\n";
  char header[200] = {'\0'};
  snprintf(header, 200, header_fmt, default_depth, default_depth, default_depth);
  const char* footer = "}";
  const GLchar* source[] = {header, fragment_shader_source_without_header, footer};
  printf("shader is:\n%s%s%s\n", header, fragment_shader_source_without_header, footer);
  glShaderSource(fs, 3, source, NULL);
  glCompileShader(fs);
  glGetShaderiv(fs, GL_COMPILE_STATUS, &compile_ok);
  if (!compile_ok) {
    fprintf(stderr, "Error in fragment shader\n");
    int log_info_length;
    glGetShaderiv(fs, GL_INFO_LOG_LENGTH, &log_info_length);
    if (log_info_length > 0 ){
      GLchar *info_log = malloc(log_info_length * sizeof(GLchar));
      glGetShaderInfoLog(fs, log_info_length, NULL, info_log);
      fprintf(stderr, "%s\n", info_log);
      free(info_log);
      info_log = NULL;
    }
    return false;
  }
  program = glCreateProgram();
  glAttachShader(program, vs);
  glAttachShader(program, fs);
  glLinkProgram(program);
  glGetProgramiv(program, GL_LINK_STATUS, &link_ok);
  if (!link_ok) {
    fprintf(stderr, "glLinkProgram:");
    return false;
  }
  const char* attribute_name = "coord2d";
  attribute_coord2d = glGetAttribLocation(program, attribute_name);
  if (attribute_coord2d == -1) {
    fprintf(stderr, "Could not bind attribute %s\n", attribute_name);
    return false;
  }
  return true;
}

void stop_on_lua_error (lua_State *L, const char *fmt, ...) {
  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);
  lua_close(L);
  // exit(EXIT_FAILURE);
}

void load_lua_fragment_shader(const char *filename, const char** fragment_shader_source, double *default_depth) {
  lua_State *L = luaL_newstate();
  luaL_openlibs(L);

  if (luaL_loadfile(L, "luacnc.lua") || lua_pcall(L, 0, 0, 0)) {
    stop_on_lua_error(L, "cannot run luacnc file: %s", lua_tostring(L, -1));
  }
  if (luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0)) {
    stop_on_lua_error(L, "cannot run luacnc file: %s", lua_tostring(L, -1));
  }
  lua_getglobal(L, "fs_src");
  if (!lua_isstring(L, -1)) {
    stop_on_lua_error(L, "error: `fs_src' shall be a string\n");
  }
  *fragment_shader_source = lua_tostring(L, -1);
  lua_getglobal(L, "default_depth");
  if (!lua_isnumber(L, -1)) {
    stop_on_lua_error(L, "error: `default_depth' shall be a number between 0.0 and 1.0 inclusive.\n");
  }
  *default_depth =  lua_tonumber(L, -1);
}

void check_and_reload_script_if_modified() {
  char buffer[EVENT_BUF_LEN];
  // Trying to read an event
  size_t evt_len = read(inotify_fd, buffer, EVENT_BUF_LEN);
  if (evt_len < 0 && errno != EAGAIN) {
    perror("read");
    exit(EXIT_FAILURE);
  }
  if (evt_len > 0) {
    // there is an event on script file
    struct inotify_event* evt = (struct inotify_event*)buffer;
    if ( evt->mask & IN_MODIFY ) {
      fprintf(stderr, "-------------- Reloading script... -----------\n");
      load_lua_fragment_shader(script_filename, &fragment_shader_source, &default_depth);
      init_resources(fragment_shader_source, default_depth);
      fprintf(stderr, "-------------- shader reloaded ---------------\n");
    } else if (evt->mask && IN_DELETE) {
      // TODO
    }
  }
  glutPostRedisplay();
}

void on_display() {
  /* Clear the background as white */
  glClearColor(1.0, 1.0, 1.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
 
  glUseProgram(program);
  glEnableVertexAttribArray(attribute_coord2d);
  GLfloat triangle_vertices[] = {
    -1.0,  1.0,
    -1.0, -1.0,
     1.0, -1.0,
    -1.0,  1.0,
     1.0, -1.0,
     1.0,  1.0
  };
  /* Describe our vertices array to OpenGL (it can't guess its format automatically) */
  glVertexAttribPointer(
    attribute_coord2d, // attribute
    2,                 // number of elements per vertex, here (x,y)
    GL_FLOAT,          // the type of each element
    GL_FALSE,          // take our values as-is
    0,                 // no extra data between each position
    triangle_vertices  // pointer to the C array
  );
 
  /* Push each element in buffer_vertices to the vertex shader */
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(attribute_coord2d);
 
  /* Display the result */
  glutSwapBuffers();
}

void free_resources() {
  glDeleteProgram(program);
}
 
int main(int argc, char *argv[]) {
  glutInit(&argc, argv);
  glutInitContextVersion(2, 0);
  glutInitWindowSize(640, 640);
  glutInitDisplayMode(GLUT_RGBA|GLUT_DOUBLE|GLUT_DEPTH);
  glutCreateWindow(PROGRAM_NAME);

  GLenum glew_status = glewInit();
  if (glew_status != GLEW_OK) {
    fprintf(stderr, "Error: %s\n", glewGetErrorString(glew_status));
    return EXIT_FAILURE;
  }
  script_filename = argv[1];
  load_lua_fragment_shader(script_filename, &fragment_shader_source, &default_depth);

  /* Watch for script modifications */
  inotify_fd = inotify_init();
  int inotify_wd = inotify_add_watch(inotify_fd, script_filename, IN_MODIFY | IN_DELETE_SELF);
  if (inotify_wd < 0) {
    fprintf(stderr, "error on inotify");
    return EXIT_FAILURE;
  }
  fcntl(inotify_fd, F_SETFL, O_NONBLOCK);

  if (init_resources(fragment_shader_source, default_depth)) {
    glutDisplayFunc(on_display);
    glutIdleFunc(check_and_reload_script_if_modified);
    glutMainLoop();
  }

  free_resources();
  //inotify_rm_watch(inotify_fd, inotify_wd);
  return EXIT_SUCCESS;
}
