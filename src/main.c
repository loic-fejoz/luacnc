#include <stdbool.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h> 
#include <GL/glew.h>
#include <GL/freeglut.h>
 
#define PROGRAM_NAME "luacnc test"

GLuint program;
GLint attribute_coord2d;

bool init_resources() {
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
  const char *fs_source =
    "#version 120           \n"
    "void main(void) {        "
    "  vec2 dist;"
    "  dist.x = gl_FragCoord.x - 320.0;"
    "  dist.y = gl_FragCoord.y - 320.0;"
    "  vec2 dist2 = dist * dist;"
    "  bool inCircle1 = (dist2.x + dist2.y < 80*80);"
    "  bool inSquare1 = (gl_FragCoord.x > 290 && gl_FragCoord.x < 350 && gl_FragCoord.y > 290 && gl_FragCoord.y < 350);"
    //    "  bool overall = inCircle1 && !inSquare1;"
    "  bool flower = (dist2.x + dist2.y) < cos(atan(dist.x, dist.y) * 6) * 102400;"
    "  bool overall = flower || inCircle1;" 
    "  if (overall) {"
    "    gl_FragColor[0] = 1.0;" // gl_FragCoord.z; "
    "    gl_FragColor[1] = 0.0; "
    "    gl_FragColor[2] = 0.0; "
    "  } else {"
    "    gl_FragColor[0] = 0.0; "
    "    gl_FragColor[1] = 0.0; "
    "    gl_FragColor[2] = 0.0; "
    "  }"
    "}";
  glShaderSource(fs, 1, &fs_source, NULL);
  glCompileShader(fs);
  glGetShaderiv(fs, GL_COMPILE_STATUS, &compile_ok);
  if (!compile_ok) {
    fprintf(stderr, "Error in fragment shader\n");
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
  if (init_resources()) {
    glutDisplayFunc(on_display);
    glutMainLoop();
  }

  free_resources();
  return EXIT_SUCCESS;
}
