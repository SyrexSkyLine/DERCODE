// Функція для створення матриці обертання планети
mat3 rotmatPlanet(float x, float y, float z) {
    float cosX = cos(x), sinX = sin(x);
    float cosY = cos(y), sinY = sin(y);
    float cosZ = cos(z), sinZ = sin(z);
    
    mat3 rotX = mat3(
        1.0, 0.0, 0.0,
        0.0, cosX, -sinX,
        0.0, sinX, cosX
    );
    
    mat3 rotY = mat3(
        cosY, 0.0, sinY,
        0.0, 1.0, 0.0,
        -sinY, 0.0, cosY
    );
    
    mat3 rotZ = mat3(
        cosZ, -sinZ, 0.0,
        sinZ, cosZ, 0.0,
        0.0, 0.0, 1.0
    );
    
    return rotZ * rotY * rotX;
}